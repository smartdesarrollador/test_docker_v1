#!/bin/bash

# Script de deploy para entorno local
# Permite commitear cambios y hacer push a GitHub

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

PROJECT_DIR="/home/jeans/proyectos/laravel-docker-test/laravel"

echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║       🚀 DEPLOY LOCAL A GITHUB            ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
echo ""

# Ir al directorio del proyecto
cd $PROJECT_DIR

# Verificar branch actual
BRANCH=$(git branch --show-current)
echo -e "${YELLOW}📍 Branch actual: ${BRANCH}${NC}"
echo ""

# Verificar si hay cambios
if [[ -z $(git status -s) ]]; then
    echo -e "${GREEN}✅ No hay cambios para commitear${NC}"
    echo ""
    read -p "¿Deseas hacer push de commits existentes? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}📤 Haciendo push a GitHub...${NC}"
        git push origin $BRANCH
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Push completado${NC}"
        else
            echo -e "${RED}❌ Error al hacer push${NC}"
            exit 1
        fi
    fi
else
    # Mostrar cambios pendientes
    echo -e "${YELLOW}📋 Cambios pendientes:${NC}"
    echo ""
    git status -s
    echo ""

    # Preguntar si commitear
    read -p "¿Deseas agregar y commitear estos cambios? (y/n): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Pedir mensaje de commit
        echo ""
        read -p "Mensaje del commit: " commit_message

        if [ -z "$commit_message" ]; then
            echo -e "${RED}❌ Mensaje de commit vacío${NC}"
            exit 1
        fi

        # Agregar cambios
        echo ""
        echo -e "${BLUE}📝 Agregando cambios...${NC}"
        git add .

        # Hacer commit
        echo -e "${BLUE}💾 Creando commit...${NC}"
        git commit -m "$commit_message"

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Commit creado${NC}"

            # Preguntar si hacer push
            echo ""
            read -p "¿Hacer push a GitHub? (y/n): " -n 1 -r
            echo ""

            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo -e "${BLUE}📤 Haciendo push a GitHub...${NC}"
                git push origin $BRANCH

                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ Push completado${NC}"
                else
                    echo -e "${RED}❌ Error al hacer push${NC}"
                    exit 1
                fi
            fi
        else
            echo -e "${RED}❌ Error al crear commit${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}Operación cancelada${NC}"
        exit 0
    fi
fi

# Preguntar si limpiar cache
echo ""
read -p "¿Limpiar cache de Laravel? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}🧹 Limpiando cache...${NC}"
    docker exec laravel-app-1 php artisan config:clear
    docker exec laravel-app-1 php artisan cache:clear
    docker exec laravel-app-1 php artisan view:clear
    echo -e "${GREEN}✅ Cache limpiado${NC}"
fi

# Preguntar si ejecutar migraciones
echo ""
read -p "¿Ejecutar migraciones? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}📊 Ejecutando migraciones...${NC}"
    docker exec laravel-app-1 php artisan migrate
    echo -e "${GREEN}✅ Migraciones ejecutadas${NC}"
fi

# Preguntar si reiniciar contenedores
echo ""
read -p "¿Reiniciar contenedores? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}🔄 Reiniciando contenedores...${NC}"
    docker compose restart app nginx
    echo -e "${GREEN}✅ Contenedores reiniciados${NC}"
fi

echo ""
echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║       ✅ DEPLOY LOCAL COMPLETADO          ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}📊 Información:${NC}"
echo -e "   🌐 URL Local: ${GREEN}http://localhost:8000${NC}"
echo -e "   🌿 Branch: ${GREEN}$BRANCH${NC}"
echo ""
