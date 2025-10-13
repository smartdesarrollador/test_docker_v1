# -----------------------------
# Etapa base: PHP-FPM con extensiones
# -----------------------------
FROM php:8.2-fpm

# Instala dependencias del sistema y extensiones PHP
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd opcache \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Habilita y optimiza OPcache para producción
RUN { \
    echo 'opcache.enable=1'; \
    echo 'opcache.memory_consumption=256'; \
    echo 'opcache.max_accelerated_files=20000'; \
    echo 'opcache.validate_timestamps=0'; \
    echo 'opcache.save_comments=1'; \
} > /usr/local/etc/php/conf.d/opcache.ini

# Copia Composer desde la imagen oficial
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN docker-php-ext-install pdo pdo_mysql
RUN pecl install redis && docker-php-ext-enable redis

# Define el directorio de trabajo
WORKDIR /var/www

# Copia todo el código fuente del proyecto
COPY . .

# Instala dependencias de producción
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader

# Ajusta permisos para Laravel
RUN chown -R www-data:www-data /var/www \
 && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Variables de entorno (puedes sobrescribirlas en docker-compose)
ENV APP_ENV=production
ENV APP_DEBUG=false

# Expone el puerto donde escucha PHP-FPM
EXPOSE 9000

# Comando por defecto
CMD ["php-fpm"]

RUN chmod -R 775 /var/www/storage /var/www/bootstrap/cache
