#!/bin/bash
set -e

echo "================================================================="
echo "ORANGEHRM PORTOS INTERNATIONAL"
echo "================================================================="
echo "$(date)"
echo ""

# --- Puerto y Apache ---
PORT=${PORT:-10000}
echo "Puerto: $PORT"
echo "Listen $PORT" > /etc/apache2/ports.conf

# Fix MPM conflict (mod_php requires prefork)
a2dismod mpm_event 2>/dev/null || true
a2dismod mpm_worker 2>/dev/null || true
a2enmod mpm_prefork 2>/dev/null || true
a2enmod rewrite 2>/dev/null || true
a2enmod proxy 2>/dev/null || true
a2enmod proxy_http 2>/dev/null || true

cat > /etc/apache2/sites-available/000-default.conf << EOF
<VirtualHost *:$PORT>
    ServerName localhost
    DocumentRoot /var/www/html

    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
        DirectoryIndex index.php index.html
    </Directory>

    Alias /api /var/www/html/api

    <Directory /var/www/html/api>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
        DirectoryIndex index.php
        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule ^(.*)$ index.php [QSA,L]
    </Directory>

    # OCR Service proxy
    ProxyPreserveHost On
    ProxyPass /ocr http://127.0.0.1:8001/ocr
    ProxyPassReverse /ocr http://127.0.0.1:8001/ocr

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# --- Variables de entorno MySQL (Railway) ---
DB_HOST="${MYSQLHOST:-localhost}"
DB_PORT="${MYSQLPORT:-3306}"
DB_NAME="${MYSQLDATABASE:-railway}"
DB_USER="${MYSQLUSER:-root}"
DB_PASS="${MYSQLPASSWORD}"

echo "MySQL: $DB_USER@$DB_HOST:$DB_PORT/$DB_NAME"

# --- Esperar MySQL ---
echo "Esperando MySQL..."
for i in $(seq 1 15); do
    if mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1" > /dev/null 2>&1; then
        echo "MySQL conectado"
        break
    fi
    echo "  intento $i/15..."
    sleep 3
done

# --- Patch MySQL 9.x compatibility ---
cd /var/www/html
find . -name "*.php" -type f -exec grep -l "mysql.*version" {} \; | head -5 | while read file; do
    if [ -f "$file" ]; then
        sed -i 's/8\.4/9\.9/g' "$file" 2>/dev/null || true
        sed -i 's/8\.3/9\.9/g' "$file" 2>/dev/null || true
    fi
done

# --- Verificar si ya esta instalado ---
TABLE_COUNT=$(mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -N -e \
    "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DB_NAME' AND table_name LIKE 'ohrm_%';" 2>/dev/null || echo "0")

if [ "$TABLE_COUNT" -gt "50" ]; then
    echo "OrangeHRM ya instalado ($TABLE_COUNT tablas ohrm_*)"
else
    echo "================================================================="
    echo "INSTALACION AUTOMATICA (bypass wizard)"
    echo "================================================================="

    # Escribir cli_install_config.yaml con datos de Railway
    cat > /var/www/html/installer/cli_install_config.yaml << EOYAML
database:
  hostName: ${DB_HOST}
  hostPort: ${DB_PORT}
  databaseName: ${DB_NAME}
  privilegedDatabaseUser: ${DB_USER}
  privilegedDatabasePassword: "${DB_PASS}"
  useSameDbUserForOrangeHRM: y
  orangehrmDatabaseUser: ~
  orangehrmDatabasePassword: ~
  isExistingDatabase: y
  enableDataEncryption: n

organization:
  name: Portos International
  country: MX

admin:
  adminUserName: admin
  adminPassword: PortosAdmin123!
  adminEmployeeFirstName: Portos
  adminEmployeeLastName: Admin
  workEmail: admin@portosinternational.com
  contactNumber: ~
  registrationConsent: false

license:
  agree: y
EOYAML

    echo "Config YAML generado. Ejecutando CLI installer..."
    cd /var/www/html
    php installer/cli_install.php && echo "CLI install EXITOSO" || {
        echo "CLI install fallo. Intentando instalacion manual via SQL..."

        # Fallback: ejecutar SQL base + migrations manualmente
        echo "Ejecutando dbscript-1.sql (schema)..."
        mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < /var/www/html/installer/Migration/V3_3_3/dbscript-1.sql 2>&1 || echo "WARN: dbscript-1 tuvo errores"

        echo "Ejecutando dbscript-2.sql (seed data)..."
        mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < /var/www/html/installer/Migration/V3_3_3/dbscript-2.sql 2>&1 || echo "WARN: dbscript-2 tuvo errores"

        # Ejecutar migrations PHP via el console
        echo "Ejecutando migrations via console..."
        php /var/www/html/installer/console install:on-existing-database --no-interaction 2>&1 || {
            echo "Console migration tambien fallo - continuando con base schema solamente"

            # Crear admin manualmente
            echo "Creando usuario admin manualmente..."
            ADMIN_HASH=$(php -r "echo password_hash('PortosAdmin123!', PASSWORD_BCRYPT, ['cost' => 12]);")

            mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" << EOSQL
-- Crear empleado admin
INSERT IGNORE INTO hs_hr_employee (employee_id, emp_lastname, emp_firstname, emp_work_email)
VALUES ('0001', 'Admin', 'Portos', 'admin@portosinternational.com');

-- Crear usuario admin
INSERT IGNORE INTO ohrm_user (user_role_id, emp_number, user_name, user_password, date_entered)
VALUES (
    (SELECT id FROM ohrm_user_role WHERE name = 'Admin' LIMIT 1),
    (SELECT emp_number FROM hs_hr_employee WHERE employee_id = '0001' LIMIT 1),
    'admin',
    '${ADMIN_HASH}',
    NOW()
);

-- Configurar organizacion
INSERT INTO ohrm_organization_gen_info (name, country) VALUES ('Portos International', 'MX')
ON DUPLICATE KEY UPDATE name = 'Portos International', country = 'MX';

UPDATE ohrm_subunit SET name = 'Portos International' WHERE level = 0;

-- Configurar idioma y registro
INSERT INTO hs_hr_config (\`key\`, value) VALUES ('admin.localization.default_language', 'es_ES')
ON DUPLICATE KEY UPDATE value = 'es_ES';
INSERT INTO hs_hr_config (\`key\`, value) VALUES ('instance.reg_consent', '0')
ON DUPLICATE KEY UPDATE value = '0';
EOSQL
            echo "Admin y organizacion creados"
        }
    }

    # Verificar instalacion
    FINAL_COUNT=$(mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -N -e \
        "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DB_NAME';" 2>/dev/null || echo "0")
    echo "Tablas en DB despues de instalacion: $FINAL_COUNT"
fi

# --- Generar Conf.php (formato OrangeHRM 5.7) ---
echo "Generando Conf.php (formato 5.7)..."
mkdir -p /var/www/html/lib/confs
cat > /var/www/html/lib/confs/Conf.php << EOPHP
<?php

class Conf
{
    private string \$dbHost;
    private string \$dbPort;
    private string \$dbName;
    private string \$dbUser;
    private string \$dbPass;

    public function __construct()
    {
        \$this->dbHost = '${DB_HOST}';
        \$this->dbPort = '${DB_PORT}';
        \$this->dbName = '${DB_NAME}';
        \$this->dbUser = '${DB_USER}';
        \$this->dbPass = '${DB_PASS}';
    }

    public function getDbHost(): string
    {
        return \$this->dbHost;
    }

    public function getDbPort(): string
    {
        return \$this->dbPort;
    }

    public function getDbName(): string
    {
        return \$this->dbName;
    }

    public function getDbUser(): string
    {
        return \$this->dbUser;
    }

    public function getDbPass(): string
    {
        return \$this->dbPass;
    }
}
EOPHP

# --- Generar encryption key si no existe ---
if [ ! -f /var/www/html/lib/confs/cryptokeys/key.ohrm ]; then
    echo "Generando encryption key..."
    mkdir -p /var/www/html/lib/confs/cryptokeys
    php -r "\$k=''; for (\$i=0;\$i<4;\$i++) \$k.=md5(random_int(10000000,99999999)); echo str_shuffle(\$k);" \
        > /var/www/html/lib/confs/cryptokeys/key.ohrm
fi

# --- Permisos ---
chown -R www-data:www-data /var/www/html/lib/confs
chmod -R 755 /var/www/html/lib/confs
chown -R www-data:www-data /var/www/html/src/cache 2>/dev/null || true
chown -R www-data:www-data /var/www/html/src/log 2>/dev/null || true

# Limpiar cache
rm -rf /var/www/html/src/cache/* 2>/dev/null || true

# PHP config
echo "log_errors = On" >> /usr/local/etc/php/php.ini
echo "error_log = /var/log/php_errors.log" >> /usr/local/etc/php/php.ini
echo "display_errors = Off" >> /usr/local/etc/php/php.ini

echo ""
echo "================================================================="
echo "PORTOS INTERNATIONAL - LISTO"
echo "================================================================="
echo "Usuario: admin / PortosAdmin123!"
echo "Empresa: Portos International"
echo "Iniciando Apache en puerto $PORT..."
echo "================================================================="
echo ""

# --- OCR Service ---
echo "Iniciando OCR Service en puerto 8001..."
cd /opt/ocr-service
export MYSQLHOST="${DB_HOST}"
export MYSQLPORT="${DB_PORT}"
export MYSQLDATABASE="${DB_NAME}"
export MYSQLUSER="${DB_USER}"
export MYSQLPASSWORD="${DB_PASS}"
/opt/ocr-venv/bin/uvicorn main:app --host 127.0.0.1 --port 8001 --log-level warning &
OCR_PID=$!
echo "OCR Service PID: $OCR_PID"
cd /var/www/html

exec apache2-foreground
