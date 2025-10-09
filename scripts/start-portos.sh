#!/bin/bash
set -e

echo "================================================================="
echo "🚀 ORANGEHRM PORTOS INTERNATIONAL - INSTALACIÓN LIMPIA"
echo "================================================================="
echo "📅 $(date)"
echo "🐳 Usando imagen oficial orangehrm/orangehrm:5.7"
echo "🏢 Empresa: Portos International - Freight Forwarding"
echo ""

# Configurar puerto para Railway (usa PORT automáticamente)
PORT=${PORT:-8080}
echo "🌐 Configurando puerto Railway: $PORT"

# Configurar Apache para Railway
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

# Configuración MySQL Railway
DB_HOST="hopper.proxy.rlwy.net"
DB_PORT="54569"
DB_NAME="railway"
DB_USER="root"
DB_PASS="LSItgfJsFdgVlFnpcDLtpCRwdCweBLKu"

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
    echo "💡 Verificar que Railway MySQL esté funcionando"
    exit 1
fi

echo "✅ Conexión MySQL exitosa"

# MySQL está nativamente soportado en OrangeHRM
echo "🔧 MySQL listo para OrangeHRM..."

# Configurar variables de entorno para OrangeHRM
export ORM_DB_HOST="$DB_HOST"
export ORM_DB_PORT="$DB_PORT"
export ORM_DB_NAME="$DB_NAME"
export ORM_DB_USER="$DB_USER"
export ORM_DB_PASSWORD="$DB_PASS"

echo "✅ MySQL Railway configurado correctamente"

# Verificar si OrangeHRM ya está instalado
echo "🔍 Verificando estado de instalación..."
table_count=$(mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DB_NAME' AND table_name LIKE 'ohrm_%';" 2>/dev/null || echo "0")

if [ "$table_count" -gt "50" ]; then
    echo "✅ OrangeHRM ya está instalado ($table_count tablas)"
    echo "🎯 Iniciando sistema existente..."
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

# Iniciar Apache
exec apache2-foreground