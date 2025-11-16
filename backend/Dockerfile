FROM php:8.2-apache

# Arguments
ARG DEBIAN_FRONTEND=noninteractive

# Install system dependencies and PHP extensions
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        unzip \
        zip \
        default-mysql-client \
        default-libmysqlclient-dev \
        libzip-dev \
        libonig-dev \
        libxml2-dev \
        libpng-dev \
        libjpeg-dev \
        libpq-dev \
        libicu-dev \
    && docker-php-ext-install pdo_mysql zip mbstring exif pcntl bcmath gd opcache \
    && rm -rf /var/lib/apt/lists/*

# Enable apache modules
RUN a2enmod rewrite

# Switch DocumentRoot to Laravel public and ensure directory permissions
RUN sed -i "s|/var/www/html|/var/www/html/public|g" /etc/apache2/sites-available/000-default.conf \
    && printf '\n<Directory /var/www/html/public>\n    AllowOverride All\n    Require all granted\n</Directory>\n' >> /etc/apache2/apache2.conf

# Set working directory
WORKDIR /var/www/html

# Copy existing application files
COPY . /var/www/html

# Ensure storage & bootstrap cache are writable
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/public || true

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer','/tmp/composer-setup.php');" \
    && php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && rm /tmp/composer-setup.php

# Run composer install (do not fail the build if composer.lock not present)
RUN if [ -f composer.json ]; then composer install --no-dev --no-scripts --no-progress --prefer-dist || true; fi

# Expose port 80
EXPOSE 80

# Start Apache in foreground
CMD ["apache2-foreground"]
