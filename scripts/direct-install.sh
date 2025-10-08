#!/bin/bash
set -e

echo "🔧 INSTALACIÓN DIRECTA VIA SQL - ORANGEHRM PORTOS"
echo "================================================="

# Variables de la base de datos
DB_HOST="dpg-d34pm0ffte5s73abeq0g-a.oregon-postgres.render.com"
DB_PORT="5432"
DB_NAME="orangehrm_portos"
DB_USER="orangehrm_user"
DB_PASS="A5xg14Ns2M4QUQ7bu0fE2GsU6WFzyOaX"

cd /var/www/html

echo "🧹 Limpiando instalación previa..."
rm -rf lib/confs/Conf.php* 2>/dev/null || true
rm -rf symfony/cache/* 2>/dev/null || true

echo "🗄️ Creando esquema base OrangeHRM..."

# Obtener y aplicar esquema base
if [ -f "installer/Migration/V5_7_0/schema.sql" ]; then
    echo "📋 Aplicando esquema oficial V5.7.0..."
    PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f installer/Migration/V5_7_0/schema.sql
elif [ -d "installer/Migration" ]; then
    # Buscar archivos SQL de migración
    echo "📋 Buscando archivos de esquema..."
    find installer/Migration -name "*.sql" -type f | head -5
    
    # Aplicar el primer esquema encontrado
    SCHEMA_FILE=$(find installer/Migration -name "*.sql" -type f | head -1)
    if [ -n "$SCHEMA_FILE" ]; then
        echo "📋 Aplicando esquema: $SCHEMA_FILE"
        PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$SCHEMA_FILE"
    fi
fi

echo "🔧 Creando configuración manual..."
mkdir -p lib/confs
cat > lib/confs/Conf.php << 'PHPEOF'
<?php
class Conf {
    var $dbhost = 'dpg-d34pm0ffte5s73abeq0g-a.oregon-postgres.render.com';
    var $dbport = '5432';
    var $dbname = 'orangehrm_portos';
    var $dbuser = 'orangehrm_user';
    var $dbpass = 'A5xg14Ns2M4QUQ7bu0fE2GsU6WFzyOaX';
}
PHPEOF

echo "👤 Creando usuario administrador..."
PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" << 'SQLEOF'
-- Insertar usuario admin si no existe
INSERT INTO ohrm_user (user_role_id, emp_number, user_name, user_password, deleted, status, date_entered, date_modified, modified_user_id, created_by)
VALUES (1, NULL, 'admin', '$2y$10$7n7l8Wd/pKOLFGqw6QX0R.YH8H5Fq2N3Wr9jMQCdBHgXxCvKf9MJG', 0, 1, NOW(), NOW(), 1, 1)
ON CONFLICT (user_name) DO NOTHING;

-- Configurar organización
INSERT INTO ohrm_organization_gen_info (name, tax_id, phone, email, country, city, zip_code, street1, note)
VALUES ('Portos International', 'PTI850314X1A', '+52 81 1234 5678', 'info@portosinternational.com', 'MX', 'Monterrey', '64000', 'Av. Constitución 2450', 'Freight Forwarding Company')
ON CONFLICT DO NOTHING;
SQLEOF

echo "✅ Instalación SQL directa completada"

# Aplicar datos de Portos
if [ -f "/var/www/html/portos/data/portos-data.sql" ]; then
    echo "🏢 Aplicando datos de Portos International..."
    PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f /var/www/html/portos/data/portos-data.sql
    echo "✅ Datos de Portos aplicados"
fi

echo "🎉 SISTEMA LISTO - ACCEDER VIA WEB"