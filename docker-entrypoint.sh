#!/bin/bash
set -e

echo "🚀 Starting OrangeHRM for Portos International..."

# Set default database values if not provided
DATABASE_HOST=${DATABASE_HOST:-dpg-d34pm0ffte5s73abeq0g-a.oregon-postgres.render.com}
DATABASE_USER=${DATABASE_USER:-orangehrm_user}
DATABASE_NAME=${DATABASE_NAME:-orangehrm_portos}
DATABASE_PASSWORD=${DATABASE_PASSWORD:-A5xg14Ns2M4QUQ7bu0fE2GsU6WFzyOaX}

echo "📊 Database config:"
echo "Host: $DATABASE_HOST"
echo "User: $DATABASE_USER"
echo "Database: $DATABASE_NAME"

# Wait for database to be ready (only if external DB)
if [ "$DATABASE_HOST" != "localhost" ] && [ "$DATABASE_HOST" != "postgres" ]; then
    echo "⏳ Waiting for external PostgreSQL database..."
    until PGPASSWORD=$DATABASE_PASSWORD psql -h "$DATABASE_HOST" -U "$DATABASE_USER" -d "$DATABASE_NAME" -c '\q' 2>/dev/null; do
      echo "PostgreSQL is unavailable - sleeping"
      sleep 2
    done
    echo "✅ PostgreSQL is ready!"
fi

# Check if installation is needed
if [ ! -f "/var/www/html/lib/confs/INSTALLED" ]; then
    echo "📦 First time setup - marking as installed..."
    touch /var/www/html/lib/confs/INSTALLED
    
    # Set permissions
    chown -R www-data:www-data /var/www/html
    chmod -R 777 /var/www/html/symfony/cache
    chmod -R 777 /var/www/html/symfony/log
    chmod -R 755 /var/www/html/lib/confs
fi

# Clear Symfony cache
echo "🧹 Clearing cache..."
rm -rf /var/www/html/symfony/cache/*
mkdir -p /var/www/html/symfony/cache
chown -R www-data:www-data /var/www/html/symfony/cache
chmod -R 777 /var/www/html/symfony/cache

echo "✅ OrangeHRM is ready!"
echo "🌐 Access at http://localhost"
echo "👤 Login: admin / PortosAdmin123!"

# Start Apache
exec "$@"