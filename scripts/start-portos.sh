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

# Usar valores directos conocidos (más confiable que parsing)
DB_HOST="dpg-d34pm0ffte5s73abeq0g-a.oregon-postgres.render.com"
DB_PORT="5432"
DB_NAME="orangehrm_portos"
DB_USER="orangehrm_user"
DB_PASS="A5xg14Ns2M4QUQ7bu0fE2GsU6WFzyOaX"

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

# Configurar PHP para PostgreSQL
echo "🔧 Configurando PHP para PostgreSQL..."
# Las extensiones ya están instaladas via docker-php-ext-install
echo "extension=pgsql" >> /usr/local/etc/php/conf.d/docker-php-ext-pgsql.ini
echo "extension=pdo_pgsql" >> /usr/local/etc/php/conf.d/docker-php-ext-pdo_pgsql.ini

# Configurar variables de entorno para OrangeHRM
export ORM_DB_HOST="$DB_HOST"
export ORM_DB_PORT="$DB_PORT"
export ORM_DB_NAME="$DB_NAME"
export ORM_DB_USER="$DB_USER"
export ORM_DB_PASSWORD="$DB_PASS"

# Crear configuración de base de datos para OrangeHRM
mkdir -p /var/www/html/lib/confs
cat > /var/www/html/lib/confs/database.yml << EOF
prod:
  doctrine:
    default_connection: default
    dbal:
      default_connection: default
      connections:
        default:
          driver: pdo_pgsql
          host: $DB_HOST
          port: $DB_PORT
          dbname: $DB_NAME
          user: $DB_USER
          password: $DB_PASS
          charset: utf8
EOF

echo "✅ PostgreSQL configurado correctamente"

# Verificar si OrangeHRM ya está instalado
echo "🔍 Verificando estado de instalación..."
table_count=$(PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public' AND table_name LIKE 'ohrm_%';" 2>/dev/null | tr -d ' ' || echo "0")

if [ "$table_count" -gt "50" ]; then
    echo "✅ OrangeHRM ya está instalado ($table_count tablas)"
    echo "🎯 Iniciando sistema existente..."
else
    echo "🌐 SISTEMA LISTO PARA INSTALACIÓN WEB"
    echo "========================================="
    echo "🎯 URL: https://orangehrm-portos-clean.onrender.com/installer"
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