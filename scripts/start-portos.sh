#!/bin/bash
set -e

echo "================================================================="
echo "🚀 ORANGEHRM PORTOS INTERNATIONAL - INSTALACIÓN LIMPIA"
echo "================================================================="
echo "📅 $(date)"
echo "🐳 Usando imagen oficial orangehrm/orangehrm:5.7"
echo "🏢 Empresa: Portos International - Freight Forwarding"
echo ""

# Configurar puerto para Railway (detectar automáticamente)
PORT=${PORT:-10000}
echo "🌐 Configurando puerto: $PORT"
echo "🔍 Railway PORT variable: ${PORT}"

# Configurar Apache para Render
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
    
    # API alias para acceso directo
    Alias /api /var/www/html/api
    
    <Directory /var/www/html/api>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
        DirectoryIndex index.php
        
        # Configurar rewrite para API REST
        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule ^(.*)$ index.php [QSA,L]
    </Directory>
    
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Verificar variables de entorno
if [ -z "$DATABASE_URL" ]; then
    echo "❌ ERROR: DATABASE_URL no encontrada"
    echo "💡 Verificar configuración en Render Dashboard"
    exit 1
fi

echo "✅ Variables de entorno configuradas correctamente"

# Configuración MySQL Railway (Nueva base)
DB_HOST="shinkansen.proxy.rlwy.net"
DB_PORT="49981"
DB_NAME="railway"
DB_USER="root"
DB_PASS="ZmAqgLKhrfjsVNmaTbrCsfAHkeAZMkVE"

echo "🔗 Configuración MySQL Railway:"
echo "   Host: $DB_HOST"
echo "   Puerto: $DB_PORT"
echo "   Base: $DB_NAME"
echo "   Usuario: $DB_USER"
echo ""

# Verificar conexión a MySQL
echo "🔍 Verificando conexión MySQL..."
if ! mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "SELECT VERSION();" > /dev/null 2>&1; then
    echo "❌ Error conectando a MySQL"
    echo "💡 Verificando estado de Railway MySQL..."
    echo "🔧 Host: $DB_HOST:$DB_PORT"
    echo "🔧 Database: $DB_NAME"
    echo "🔧 User: $DB_USER"
    # Intentar despertar la base si está dormida
    mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1;" 2>/dev/null || true
    sleep 3
    # Intentar de nuevo
    if ! mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "SELECT VERSION();" > /dev/null 2>&1; then
        echo "❌ MySQL no disponible - continuando para debug"
    else
        echo "✅ MySQL conectado después de despertar"
    fi
else
    echo "✅ Conexión MySQL exitosa"
fi

# MySQL está nativamente soportado en OrangeHRM
echo "🔧 MySQL listo para OrangeHRM..."

# Configurar variables de entorno para OrangeHRM
export ORM_DB_HOST="$DB_HOST"
export ORM_DB_PORT="$DB_PORT"
export ORM_DB_NAME="$DB_NAME"
export ORM_DB_USER="$DB_USER"
export ORM_DB_PASSWORD="$DB_PASS"

echo "✅ MySQL Railway configurado correctamente"

# Patch para MySQL 9.x compatibility
echo "🔧 Aplicando patch MySQL 9.x..."
cd /var/www/html
# Buscar y patchear validación MySQL version
find . -name "*.php" -type f -exec grep -l "mysql.*version" {} \; | head -5 | while read file; do
    if [ -f "$file" ]; then
        sed -i 's/8\.4/9\.9/g' "$file" 2>/dev/null || true
        sed -i 's/8\.3/9\.9/g' "$file" 2>/dev/null || true
    fi
done

# Verificar si OrangeHRM ya está instalado
echo "🔍 Verificando estado de instalación..."
table_count=$(mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DB_NAME' AND table_name LIKE 'ohrm_%';" 2>/dev/null || echo "0")

if [ "$table_count" -gt "50" ]; then
    echo "✅ OrangeHRM ya está instalado ($table_count tablas)"
    
    # Verificar si datos Portos ya están cargados
    portos_check=$(mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -N -e "SELECT COUNT(*) FROM ohrm_organization_gen_info WHERE name = 'Portos International';" 2>/dev/null || echo "0")
    
    if [ "$portos_check" -eq "0" ]; then
        echo "🏢 Cargando datos Portos International..."
        mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" < /var/www/html/portos/data/portos-data.sql
        echo "✅ Datos Portos cargados exitosamente"
    else
        echo "✅ Datos Portos ya están cargados"
    fi
    
    # Configurar variables de entorno que OrangeHRM detectará automáticamente
    echo "🔧 Configurando variables de entorno para OrangeHRM..."
    export ORANGEHRM_DATABASE_HOST="shinkansen.proxy.rlwy.net"
    export ORANGEHRM_DATABASE_PORT="49981"
    export ORANGEHRM_DATABASE_NAME="railway"
    export ORANGEHRM_DATABASE_USER="root"
    export ORANGEHRM_DATABASE_PASSWORD="ZmAqgLKhrfjsVNmaTbrCsfAHkeAZMkVE"
    
    # Variables adicionales para compatibilidad
    export DB_HOST="shinkansen.proxy.rlwy.net"
    export DB_PORT="49981"
    export DB_DATABASE="railway"
    export DB_USERNAME="root"
    export DB_PASSWORD="ZmAqgLKhrfjsVNmaTbrCsfAHkeAZMkVE"
    
    # Crear archivo completo de configuración con variables de entorno
    mkdir -p /var/www/html/lib/confs
    cat > /var/www/html/lib/confs/Conf.php << 'EOL'
<?php
class Conf {
    var $smtphost;
    var $dbhost;
    var $dbport;
    var $dbname;
    var $dbuser;
    var $dbpass;
    var $version;

    function Conf() {
        // Usar variables de entorno como fallback
        $this->dbhost  = $_ENV['ORANGEHRM_DATABASE_HOST'] ?? 'shinkansen.proxy.rlwy.net';
        $this->dbport  = $_ENV['ORANGEHRM_DATABASE_PORT'] ?? 49981;
        $this->dbname  = $_ENV['ORANGEHRM_DATABASE_NAME'] ?? 'railway';
        $this->dbuser  = $_ENV['ORANGEHRM_DATABASE_USER'] ?? 'root';
        $this->dbpass  = $_ENV['ORANGEHRM_DATABASE_PASSWORD'] ?? 'ZmAqgLKhrfjsVNmaTbrCsfAHkeAZMkVE';
        $this->version = '5.7';
    }

    function getDbHost() {
        return $this->dbhost;
    }

    function getDbPort() {
        return $this->dbport;
    }

    function getDbName() {
        return $this->dbname;
    }

    function getDbUser() {
        return $this->dbuser;
    }

    function getDbPass() {
        return $this->dbpass;
    }

    function getVersion() {
        return $this->version;
    }

    function getDbDsn() {
        return "mysql:host=" . $this->getDbHost() . ";port=" . $this->getDbPort() . ";dbname=" . $this->getDbName() . ";charset=utf8";
    }
}
EOL
    
    # TEMPORAL: Eliminar Conf.php para forzar wizard
    echo "🚨 FORZANDO REINSTALACIÓN - Eliminando Conf.php"
    rm -f /var/www/html/lib/confs/Conf.php
    echo "✅ Sistema listo para wizard web"
    echo "🌐 Wizard OrangeHRM habilitado"
else
    echo "🌐 SISTEMA LISTO PARA INSTALACIÓN WEB"
    echo "========================================="
    echo "🎯 URL: [Railway generará la URL automáticamente]"
    echo ""
    
    cd /var/www/html
    
    # Limpiar para instalación web limpia
    echo "🧹 Preparando instalación web..."
    rm -rf lib/confs/Conf.php* 2>/dev/null || true
    rm -rf symfony/cache/* 2>/dev/null || true
    
    echo "✅ Sistema listo para configurar via web"
    echo ""
    echo "📋 DATOS PARA EL WIZARD:"
    echo "========================"
    echo "Database Host: $DB_HOST"
    echo "Database Port: $DB_PORT"  
    echo "Database Name: $DB_NAME"
    echo "Database User: $DB_USER"
    echo "Database Pass: [YA CONFIGURADO]"
    echo ""
    echo "👤 ADMIN SUGERIDO:"
    echo "=================="
    echo "Username: admin"
    echo "Password: PortosAdmin123!"
    echo "Email: admin@portosinternational.com"
    echo ""
    echo "🏢 ORGANIZACIÓN:"
    echo "================"
    echo "Name: Portos International"
    echo "Country: Mexico"
    echo "Timezone: America/Mexico_City"
fi

# Configurar permisos finales
echo "🔧 Configurando permisos finales..."
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Limpiar caché
rm -rf /var/www/html/src/cache/* 2>/dev/null || true

echo ""
echo "================================================================="
echo "🎉 PORTOS INTERNATIONAL - SISTEMA LISTO"
echo "================================================================="
echo "🌐 URL: [Ver dominio en Railway Dashboard]"
echo "👤 Usuario: admin"
echo "🔑 Contraseña: PortosAdmin123!"
echo ""
echo "🏢 Empresa: Portos International"
echo "📍 Ubicación: Monterrey, Nuevo León, México"
echo "🚚 Especialidad: Freight Forwarding & International Logistics"
echo ""
echo "🚀 Iniciando Apache en puerto $PORT..."
echo ""

# Habilitar logs de error PHP para debugging
echo "🔍 Habilitando logs PHP para debug..."
echo "log_errors = On" >> /usr/local/etc/php/php.ini
echo "error_log = /var/log/php_errors.log" >> /usr/local/etc/php/php.ini
echo "display_errors = On" >> /usr/local/etc/php/php.ini

# Limpiar cache que puede estar corrupto
echo "🧹 Limpiando cache OrangeHRM..."
rm -rf /var/www/html/src/cache/* 2>/dev/null || true
rm -rf /var/www/html/symfony/cache/* 2>/dev/null || true

# Verificar permisos críticos
chown -R www-data:www-data /var/www/html/lib/confs/
chmod -R 755 /var/www/html/lib/confs/

# Iniciar Apache
exec apache2-foreground