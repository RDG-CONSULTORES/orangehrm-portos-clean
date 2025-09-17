#!/bin/bash
set -e

echo "🚀 Starting OrangeHRM for Portos International..."

# Wait for database to be ready
echo "⏳ Waiting for PostgreSQL database..."
until PGPASSWORD=$DATABASE_PASSWORD psql -h "$DATABASE_HOST" -U "$DATABASE_USER" -d "$DATABASE_NAME" -c '\q' 2>/dev/null; do
  echo "PostgreSQL is unavailable - sleeping"
  sleep 2
done
echo "✅ PostgreSQL is ready!"

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