# OrangeHRM Dockerfile - PostgreSQL Edition
FROM php:8.0-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libicu-dev \
    libxml2-dev \
    libzip-dev \
    libpq-dev \
    libldap2-dev \
    curl \
    wget \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
    && docker-php-ext-install -j$(nproc) \
    gd \
    intl \
    pdo \
    pdo_pgsql \
    zip \
    opcache \
    soap \
    bcmath \
    ldap \
    && pecl install apcu \
    && docker-php-ext-enable apcu

# Enable Apache modules
RUN a2enmod rewrite headers expires

# Set working directory
WORKDIR /var/www/html

# Download OrangeHRM 5.7
RUN wget -q https://github.com/orangehrm/orangehrm/releases/download/v5.7/orangehrm-5.7.zip \
    && unzip -q orangehrm-5.7.zip \
    && mv orangehrm-5.7/* . \
    && mv orangehrm-5.7/.htaccess . \
    && rmdir orangehrm-5.7 \
    && rm orangehrm-5.7.zip

# Copy pre-configured files
COPY config/Conf.php lib/confs/Conf.php
COPY config/parameters.yml symfony/config/parameters.yml
COPY config/doctrine.yml symfony/config/doctrine.yml
COPY config/log_settings.php src/config/log_settings.php

# Copy initialization scripts
COPY scripts/ /docker-entrypoint-initdb.d/

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 777 symfony/cache symfony/log lib/confs

# Copy custom Apache configuration
COPY config/apache-vhost.conf /etc/apache2/sites-available/000-default.conf

# Copy and set entrypoint
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]