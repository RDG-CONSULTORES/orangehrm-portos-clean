#!/bin/bash
set -e

echo "🚀 SCRIPT DE AUTO-INSTALACIÓN ORANGEHRM PORTOS"
echo "=============================================="

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

echo "📋 Creando configuración de base de datos..."
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

echo "🔧 Ejecutando instalación automática vía expects..."
expect << 'EXPECTEOF'
set timeout 120
spawn php installer/console install:on-new-database

# License acceptance
expect "I accept the terms in the License Agreement (yes/no)" {
    send "yes\r"
}

# Database Host
expect "Database Host Name" {
    send "dpg-d34pm0ffte5s73abeq0g-a.oregon-postgres.render.com\r"
}

# Database Port
expect "Database Port" {
    send "5432\r"
}

# Database Name
expect "Database Name" {
    send "orangehrm_portos\r"
}

# Database Username
expect "Database Username" {
    send "orangehrm_user\r"
}

# Database Password
expect "Database Password" {
    send "A5xg14Ns2M4QUQ7bu0fE2GsU6WFzyOaX\r"
}

# OrangeHRM Database Username
expect "OrangeHRM Database Username" {
    send "orangehrm_user\r"
}

# OrangeHRM Database Password
expect "OrangeHRM Database Password" {
    send "A5xg14Ns2M4QUQ7bu0fE2GsU6WFzyOaX\r"
}

# Admin Username
expect "Admin Username" {
    send "admin\r"
}

# Admin Password
expect "Admin Password" {
    send "PortosAdmin123!\r"
}

# Confirm Admin Password
expect "Confirm Admin Password" {
    send "PortosAdmin123!\r"
}

# Admin First Name
expect "Admin First Name" {
    send "Administrador\r"
}

# Admin Last Name
expect "Admin Last Name" {
    send "Portos\r"
}

# Admin Email
expect "Admin Email" {
    send "admin@portosinternational.com\r"
}

# Organization Name
expect "Organization Name" {
    send "Portos International\r"
}

# Country
expect "Country" {
    send "MX\r"
}

# Language
expect "Language" {
    send "es\r"
}

# Timezone
expect "Timezone" {
    send "America/Mexico_City\r"
}

# Registration Consent
expect "Registration Consent" {
    send "yes\r"
}

expect eof
EXPECTEOF

echo "✅ Instalación automatizada completada"

# Aplicar datos de Portos
if [ -f "/var/www/html/portos/data/portos-data.sql" ]; then
    echo "🏢 Aplicando datos de Portos International..."
    PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f /var/www/html/portos/data/portos-data.sql
    echo "✅ Datos de Portos aplicados"
fi

echo "🎉 INSTALACIÓN COMPLETA"