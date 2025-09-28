#!/bin/bash

echo "🚀 Inicializando aplicación Laravel..."

# Esperar a que MySQL esté listo
echo "⏳ Esperando a que MySQL esté listo..."
while ! docker-compose exec mysql mysqladmin ping -h"localhost" --silent; do
    sleep 1
done

echo "✅ MySQL está listo!"

# Copiar .env si no existe
if [ ! -f .env ]; then
    echo "📄 Copiando archivo .env..."
    cp .env.example .env
fi

# Instalar dependencias de composer
echo "📦 Instalando dependencias de Composer..."
docker-compose exec app composer install

# Generar key de aplicación
echo "🔑 Generando application key..."
docker-compose exec app php artisan key:generate

# Ejecutar migraciones
echo "🗄️ Ejecutando migraciones..."
docker-compose exec app php artisan migrate --force

# Configurar cache
echo "💾 Configurando cache..."
docker-compose exec app php artisan config:cache
docker-compose exec app php artisan route:cache

# Configurar permisos
echo "🔧 Configurando permisos..."
docker-compose exec app chown -R www-data:www-data /var/www/storage
docker-compose exec app chown -R www-data:www-data /var/www/bootstrap/cache
docker-compose exec app chmod -R 775 /var/www/storage
docker-compose exec app chmod -R 775 /var/www/bootstrap/cache

echo "🎉 ¡Aplicación Laravel lista!"
echo "🌐 Accede a: http://localhost:8000"
echo "🗄️ phpMyAdmin: http://localhost:8080"