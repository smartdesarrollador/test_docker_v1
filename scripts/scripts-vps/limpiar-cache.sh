#!/bin/bash

# Script para limpiar cache de Laravel en Docker
# Autor: Tu nombre
# Fecha: $(date +%Y-%m-%d)

# Colores para mensajes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Nombre del contenedor
CONTAINER_NAME="api-laravel-1-app"

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}   Limpiando cache de Laravel - API Project    ${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Función para ejecutar comando en el contenedor
run_artisan() {
    echo -e "${YELLOW}→ Ejecutando:${NC} php artisan $1"
    sudo docker exec -it $CONTAINER_NAME php artisan $1
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Completado${NC}"
    else
        echo -e "${RED}✗ Error${NC}"
    fi
    echo ""
}

# Limpiar configuración
run_artisan "config:clear"

# Limpiar cache de aplicación
run_artisan "cache:clear"

# Limpiar cache de rutas
run_artisan "route:clear"

# Limpiar cache de vistas
run_artisan "view:clear"

# Limpiar eventos cacheados
run_artisan "event:clear"

# Opcional: Optimizar autoloader de Composer
echo -e "${YELLOW}→ Optimizando Composer autoloader...${NC}"
sudo docker exec -it $CONTAINER_NAME composer dump-autoload -o
echo -e "${GREEN}✓ Completado${NC}"
echo ""

echo -e "${BLUE}================================================${NC}"
echo -e "${GREEN}✓ Cache limpiado exitosamente${NC}"
echo -e "${BLUE}================================================${NC}"
