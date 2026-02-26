#!/bin/bash
set -e

echo "================================================================="
echo "ORANGEHRM PORTOS INTERNATIONAL - INSTALACION LIMPIA"
echo "================================================================="
echo "$(date)"
echo "Usando imagen oficial orangehrm/orangehrm:5.7"
echo "Empresa: Portos International - Freight Forwarding"
echo ""

# Configurar puerto para Railway (detectar automaticamente)
PORT=${PORT:-10000}
echo "Configurando puerto: $PORT"

# Configurar Apache
echo "Listen $PORT" > /etc/apache2/ports.conf

# Habilitar mod_rewrite para API
a2enmod rewrite

cat > /etc/apache2/sites-available/000-default.conf << EOF
<VirtualHost *:$PORT>
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

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Usar variables de entorno de Railway (inyectadas automaticamente via service references)
DB_HOST="${MYSQLHOST:-localhost}"
DB_PORT="${MYSQLPORT:-3306}"
DB_NAME="${MYSQLDATABASE:-railway}"
DB_USER="${MYSQLUSER:-root}"
DB_PASS="${MYSQLPASSWORD}"

if [ -z "$DB_PASS" ]; then
    echo "ERROR: MYSQLPASSWORD no encontrada. Verificar variable reference en Railway."
    echo "Continuando para permitir wizard web..."
fi

echo "Configuracion MySQL Railway:"
echo "   Host: $DB_HOST"
echo "   Puerto: $DB_PORT"
echo "   Base: $DB_NAME"
echo "   Usuario: $DB_USER"
echo ""

# Verificar conexion a MySQL
echo "Verificando conexion MySQL..."
if mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "SELECT VERSION();" > /dev/null 2>&1; then
    echo "Conexion MySQL exitosa"
else
    echo "MySQL no disponible aun - reintentando en 5s..."
    sleep 5
    if mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "SELECT VERSION();" > /dev/null 2>&1; then
        echo "MySQL conectado despues de espera"
    else
        echo "MySQL no disponible - continuando con wizard web"
    fi
fi

# Configurar variables de entorno para OrangeHRM
export ORM_DB_HOST="$DB_HOST"
export ORM_DB_PORT="$DB_PORT"
export ORM_DB_NAME="$DB_NAME"
export ORM_DB_USER="$DB_USER"
export ORM_DB_PASSWORD="$DB_PASS"
export ORANGEHRM_DATABASE_HOST="$DB_HOST"
export ORANGEHRM_DATABASE_PORT="$DB_PORT"
export ORANGEHRM_DATABASE_NAME="$DB_NAME"
export ORANGEHRM_DATABASE_USER="$DB_USER"
export ORANGEHRM_DATABASE_PASSWORD="$DB_PASS"

echo "MySQL Railway configurado correctamente"

# Patch para MySQL 9.x compatibility
echo "Aplicando patch MySQL 9.x..."
cd /var/www/html
find . -name "*.php" -type f -exec grep -l "mysql.*version" {} \; | head -5 | while read file; do
    if [ -f "$file" ]; then
        sed -i 's/8\.4/9\.9/g' "$file" 2>/dev/null || true
        sed -i 's/8\.3/9\.9/g' "$file" 2>/dev/null || true
    fi
done

# Verificar si OrangeHRM ya esta instalado
echo "Verificando estado de instalacion..."
table_count=$(mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DB_NAME' AND table_name LIKE 'ohrm_%';" 2>/dev/null || echo "0")

if [ "$table_count" -gt "50" ]; then
    echo "OrangeHRM ya esta instalado ($table_count tablas)"

    # Verificar si datos Portos ya estan cargados
    portos_check=$(mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -N -e "SELECT COUNT(*) FROM ohrm_organization_gen_info WHERE name = 'Portos International';" 2>/dev/null || echo "0")

    if [ "$portos_check" -eq "0" ]; then
        echo "Cargando datos Portos International..."
        mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" < /var/www/html/portos/data/portos-data.sql
        echo "Datos Portos cargados exitosamente"
    else
        echo "Datos Portos ya estan cargados"
    fi

    # Crear Conf.php dinamico con variables de entorno
    mkdir -p /var/www/html/lib/confs
    cat > /var/www/html/lib/confs/Conf.php << EOPHP
<?php
class Conf {
    var \$smtphost;
    var \$dbhost;
    var \$dbport;
    var \$dbname;
    var \$dbuser;
    var \$dbpass;
    var \$version;

    function Conf() {
        \$this->dbhost  = '${DB_HOST}';
        \$this->dbport  = ${DB_PORT};
        \$this->dbname  = '${DB_NAME}';
        \$this->dbuser  = '${DB_USER}';
        \$this->dbpass  = '${DB_PASS}';
        \$this->version = '5.7';
    }

    function getDbHost() { return \$this->dbhost; }
    function getDbPort() { return \$this->dbport; }
    function getDbName() { return \$this->dbname; }
    function getDbUser() { return \$this->dbuser; }
    function getDbPass() { return \$this->dbpass; }
    function getVersion() { return \$this->version; }
    function getDbDsn() {
        return "mysql:host=" . \$this->getDbHost() . ";port=" . \$this->getDbPort() . ";dbname=" . \$this->getDbName() . ";charset=utf8";
    }
}
EOPHP

    echo "Conf.php generado con variables de entorno"
else
    echo "SISTEMA LISTO PARA INSTALACION WEB (Wizard)"
    echo "========================================="

    cd /var/www/html

    # Limpiar para instalacion web limpia
    rm -rf lib/confs/Conf.php* 2>/dev/null || true
    rm -rf symfony/cache/* 2>/dev/null || true

    echo ""
    echo "DATOS PARA EL WIZARD:"
    echo "========================"
    echo "Database Host: $DB_HOST"
    echo "Database Port: $DB_PORT"
    echo "Database Name: $DB_NAME"
    echo "Database User: $DB_USER"
    echo ""
    echo "ADMIN SUGERIDO:"
    echo "=================="
    echo "Username: admin"
    echo "Password: PortosAdmin123!"
    echo "Email: admin@portosinternational.com"
    echo ""
    echo "ORGANIZACION:"
    echo "================"
    echo "Name: Portos International"
    echo "Country: Mexico"
    echo "Timezone: America/Mexico_City"
fi

# Configurar permisos finales
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Limpiar cache
rm -rf /var/www/html/src/cache/* 2>/dev/null || true
rm -rf /var/www/html/symfony/cache/* 2>/dev/null || true

echo ""
echo "================================================================="
echo "PORTOS INTERNATIONAL - SISTEMA LISTO"
echo "================================================================="
echo "Usuario: admin"
echo "Password: PortosAdmin123!"
echo ""
echo "Empresa: Portos International"
echo "Ubicacion: Monterrey, Nuevo Leon, Mexico"
echo "Especialidad: Freight Forwarding & International Logistics"
echo ""
echo "Iniciando Apache en puerto $PORT..."
echo ""

# Habilitar logs PHP
echo "log_errors = On" >> /usr/local/etc/php/php.ini
echo "error_log = /var/log/php_errors.log" >> /usr/local/etc/php/php.ini
echo "display_errors = On" >> /usr/local/etc/php/php.ini

# Permisos criticos
mkdir -p /var/www/html/lib/confs
chown -R www-data:www-data /var/www/html/lib/confs/
chmod -R 755 /var/www/html/lib/confs/

# Iniciar Apache
exec apache2-foreground
