# OrangeHRM Portos International - Instalación Limpia
FROM orangehrm/orangehrm:5.7

# Configurar zona horaria para México
ENV TZ=America/Mexico_City
ENV DEBIAN_FRONTEND=noninteractive

# Instalar utilidades adicionales para MySQL
RUN apt-get update && apt-get install -y \
    default-mysql-client \
    curl \
    expect \
    && rm -rf /var/lib/apt/lists/*

# MySQL ya está soportado nativamente en la imagen OrangeHRM

# Crear directorios necesarios
RUN mkdir -p /var/www/html/portos/config \
             /var/www/html/portos/scripts \
             /var/www/html/portos/data \
             /var/www/html/api

# Copiar archivos de configuración
COPY config/ /var/www/html/portos/config/
COPY scripts/ /var/www/html/portos/scripts/
COPY data/ /var/www/html/portos/data/
COPY api/ /var/www/html/api/

# Copiar sistema auxiliar (no sobrescribir index.php de OrangeHRM)
# COPY index.php /var/www/html/index.php
COPY dashboard.php /var/www/html/portos-dashboard.php

# Hacer scripts ejecutables
RUN chmod +x /var/www/html/portos/scripts/*.sh

# Script de inicio personalizado para Portos
COPY scripts/start-portos.sh /usr/local/bin/start-portos.sh
RUN chmod +x /usr/local/bin/start-portos.sh

# Configurar permisos
RUN chown -R www-data:www-data /var/www/html/portos
RUN chmod -R 755 /var/www/html/portos

# Puerto para Railway (configurado en 10000)
EXPOSE 10000

# Usar nuestro script de inicio personalizado
CMD ["/usr/local/bin/start-portos.sh"]