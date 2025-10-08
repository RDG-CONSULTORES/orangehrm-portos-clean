# OrangeHRM Portos International - Instalación Limpia
FROM orangehrm/orangehrm:5.7

# Configurar zona horaria para México
ENV TZ=America/Mexico_City
ENV DEBIAN_FRONTEND=noninteractive

# Instalar utilidades adicionales para PostgreSQL y expect
RUN apt-get update && apt-get install -y \
    postgresql-client \
    curl \
    expect \
    && rm -rf /var/lib/apt/lists/*

# Crear directorios necesarios
RUN mkdir -p /var/www/html/portos/config \
             /var/www/html/portos/scripts \
             /var/www/html/portos/data

# Copiar archivos de configuración
COPY config/ /var/www/html/portos/config/
COPY scripts/ /var/www/html/portos/scripts/
COPY data/ /var/www/html/portos/data/

# Hacer scripts ejecutables
RUN chmod +x /var/www/html/portos/scripts/*.sh

# Script de inicio personalizado para Portos
COPY scripts/start-portos.sh /usr/local/bin/start-portos.sh
RUN chmod +x /usr/local/bin/start-portos.sh

# Configurar permisos
RUN chown -R www-data:www-data /var/www/html/portos
RUN chmod -R 755 /var/www/html/portos

# Puerto para Render
EXPOSE 10000

# Usar nuestro script de inicio personalizado
CMD ["/usr/local/bin/start-portos.sh"]