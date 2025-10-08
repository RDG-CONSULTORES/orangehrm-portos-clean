#!/bin/bash
set -e

echo "================================================================="
echo "🚀 ORANGEHRM PORTOS INTERNATIONAL - INSTALACIÓN LIMPIA"
echo "================================================================="
echo "📅 $(date)"
echo "🐳 Usando imagen oficial orangehrm/orangehrm:5.7"
echo "🏢 Empresa: Portos International - Freight Forwarding"
echo ""

# Configurar puerto de Render
PORT=${PORT:-10000}
echo "🌐 Configurando puerto: $PORT"

# Configurar Apache para Render
echo "Listen $PORT" > /etc/apache2/ports.conf

cat > /etc/apache2/sites-available/000-default.conf << EOF
<VirtualHost *:$PORT>
    DocumentRoot /var/www/html
    
    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
        DirectoryIndex index.php index.html
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

# Parsear DATABASE_URL
DB_HOST=$(echo $DATABASE_URL | sed 's/.*@\([^:]*\).*/\1/')
DB_PORT=$(echo $DATABASE_URL | sed 's/.*:\([0-9]*\)\/.*/\1/')
DB_NAME=$(echo $DATABASE_URL | sed 's/.*\/\([^?]*\).*/\1/')
DB_USER=$(echo $DATABASE_URL | sed 's/.*:\/\/\([^:]*\):.*/\1/')
DB_PASS=$(echo $DATABASE_URL | sed 's/.*:\/\/[^:]*:\([^@]*\)@.*/\1/')

echo "🔗 Configuración PostgreSQL:"
echo "   Host: $DB_HOST"
echo "   Puerto: $DB_PORT"
echo "   Base: $DB_NAME"
echo "   Usuario: $DB_USER"
echo ""

# Verificar conexión a PostgreSQL
echo "🔍 Verificando conexión PostgreSQL..."
if ! PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT version();" > /dev/null 2>&1; then
    echo "❌ Error conectando a PostgreSQL"
    echo "💡 Verificar que orangehrm-portos-db esté funcionando en Render"
    exit 1
fi

echo "✅ Conexión PostgreSQL exitosa"

# Verificar si OrangeHRM ya está instalado
echo "🔍 Verificando estado de instalación..."
table_count=$(PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public' AND table_name LIKE 'ohrm_%';" 2>/dev/null | tr -d ' ' || echo "0")

if [ "$table_count" -gt "50" ]; then
    echo "✅ OrangeHRM ya está instalado ($table_count tablas)"
    echo "🎯 Iniciando sistema existente..."
else
    echo "🔧 OrangeHRM no está instalado - ejecutando instalación automática..."
    
    # Ejecutar instalación limpia
    if [ -f "/var/www/html/portos/scripts/install-orangehrm.sh" ]; then
        echo "🚀 Ejecutando instalación automática..."
        bash /var/www/html/portos/scripts/install-orangehrm.sh
    else
        echo "🔧 Instalación manual via CLI..."
        cd /var/www/html
        
        # Crear configuración temporal
        mkdir -p lib/confs
        cat > lib/confs/Conf.php << PHPEOF
<?php
class Conf {
    var \$dbhost = '$DB_HOST';
    var \$dbport = '$DB_PORT';
    var \$dbname = '$DB_NAME';
    var \$dbuser = '$DB_USER';
    var \$dbpass = '$DB_PASS';
}
PHPEOF
        
        # Ejecutar instalador CLI
        php installer/console install:on-new-database \
            --db-type="pgsql" \
            --db-host="$DB_HOST" \
            --db-port="$DB_PORT" \
            --db-name="$DB_NAME" \
            --db-user="$DB_USER" \
            --db-password="$DB_PASS" \
            --admin-username="admin" \
            --admin-password="PortosAdmin123!" \
            --admin-first-name="Administrador" \
            --admin-last-name="Portos" \
            --admin-email="admin@portosinternational.com" \
            --organization-name="Portos International" \
            --country="MX" \
            --timezone="America/Mexico_City" \
            --registration-consent \
            --no-interaction
        
        echo "✅ Instalación CLI completada"
        
        # Aplicar datos de Portos si existen
        if [ -f "/var/www/html/portos/data/portos-data.sql" ]; then
            echo "🏢 Aplicando datos de Portos International..."
            PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f /var/www/html/portos/data/portos-data.sql
            echo "✅ Datos de Portos aplicados"
        fi
    fi
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
echo "🌐 URL: https://orangehrm-portos-clean.onrender.com"
echo "👤 Usuario: admin"
echo "🔑 Contraseña: PortosAdmin123!"
echo ""
echo "🏢 Empresa: Portos International"
echo "📍 Ubicación: Monterrey, Nuevo León, México"
echo "🚚 Especialidad: Freight Forwarding & International Logistics"
echo ""
echo "🚀 Iniciando Apache en puerto $PORT..."
echo ""

# Iniciar Apache
exec apache2-foreground