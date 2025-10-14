#!/bin/bash

# Script para limpiar cache de Laravel en Docker (Entorno Local)
# Autor: Sistema Laravel API
# Fecha: $(date +%Y-%m-%d)

# Colores para mensajes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Nombre del contenedor
CONTAINER_NAME="laravel-app-1"

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}   Limpiando cache de Laravel - LOCAL          ${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Función para ejecutar comando en el contenedor
run_artisan() {
    echo -e "${YELLOW}→ Ejecutando:${NC} php artisan $1"
    docker exec $CONTAINER_NAME php artisan $1

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
docker exec $CONTAINER_NAME composer dump-autoload -o
echo -e "${GREEN}✓ Completado${NC}"
echo ""

echo -e "${BLUE}================================================${NC}"
echo -e "${GREEN}✓ Cache limpiado exitosamente${NC}"
echo -e "${BLUE}================================================${NC}"
