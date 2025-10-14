#!/bin/bash

# Script de deploy automático
# Sincroniza código desde Git y reinicia si es necesario

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

PROJECT_DIR="$HOME/proyectos/proyecto-1/api-laravel-1"

echo -e "${BLUE}🚀 INICIANDO DEPLOY...${NC}"
echo ""

# Ir al directorio del proyecto
cd $PROJECT_DIR

# Verificar branch actual
BRANCH=$(git branch --show-current)
echo -e "${YELLOW}📍 Branch actual: ${BRANCH}${NC}"
echo ""

# Guardar cambios locales si existen (por si acaso)
if [[ -n $(git status -s) ]]; then
    echo -e "${YELLOW}⚠️  Hay cambios locales, guardando...${NC}"
    git stash
fi

# Pull desde GitHub
echo -e "${BLUE}📥 Descargando cambios desde GitHub...${NC}"
git pull origin main

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Código actualizado${NC}"
else
    echo -e "${RED}❌ Error al actualizar código${NC}"
    exit 1
fi

# Preguntar si limpiar cache
echo ""
read -p "¿Limpiar cache de Laravel? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}🧹 Limpiando cache...${NC}"
    sudo docker exec -it api-laravel-1-app php artisan config:clear
    sudo docker exec -it api-laravel-1-app php artisan cache:clear
    sudo docker exec -it api-laravel-1-app php artisan view:clear
    echo -e "${GREEN}✅ Cache limpiado${NC}"
fi

# Preguntar si ejecutar migraciones
echo ""
read -p "¿Ejecutar migraciones? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}📊 Ejecutando migraciones...${NC}"
    sudo docker exec -it api-laravel-1-app php artisan migrate --force
    echo -e "${GREEN}✅ Migraciones ejecutadas${NC}"
fi

# Preguntar si reiniciar contenedores
echo ""
read -p "¿Reiniciar contenedores? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}🔄 Reiniciando contenedores...${NC}"
    sudo docker compose restart app nginx
    echo -e "${GREEN}✅ Contenedores reiniciados${NC}"
fi

echo ""
echo -e "${GREEN}✅ DEPLOY COMPLETADO${NC}"
echo -e "${BLUE}🌐 https://api.smartdigitaltec.com${NC}"