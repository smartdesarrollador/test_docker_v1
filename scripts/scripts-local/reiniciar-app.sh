#!/bin/bash

# Script para reiniciar la aplicación Laravel completa (Entorno Local)
# Autor: Sistema Laravel API
# Fecha: $(date +%Y-%m-%d)

# Colores para mensajes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuración
PROJECT_DIR="/home/jeans/proyectos/laravel-docker-test/laravel"
CONTAINER_APP="laravel-app-1"
CONTAINER_NGINX="laravel-nginx-1"
CONTAINER_MYSQL="laravel-mysql-1"
CONTAINER_REDIS="laravel-redis-1"

echo ""
echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   🔄 REINICIANDO APLICACIÓN LARAVEL       ║${NC}"
echo -e "${CYAN}║              (LOCAL)                       ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
echo ""

# Función para mostrar paso
show_step() {
    echo -e "${BLUE}┌─ $1${NC}"
}

# Función para mostrar éxito
show_success() {
    echo -e "${GREEN}└─ ✓ $1${NC}"
    echo ""
}

# Función para mostrar error
show_error() {
    echo -e "${RED}└─ ✗ $1${NC}"
    echo ""
}

# Paso 1: Ir al directorio del proyecto
show_step "Navegando al directorio del proyecto..."
cd $PROJECT_DIR
if [ $? -eq 0 ]; then
    show_success "Directorio: $PROJECT_DIR"
else
    show_error "No se pudo acceder al directorio"
    exit 1
fi

# Paso 2: Verificar estado actual
show_step "Verificando estado actual de contenedores..."
docker compose ps
echo ""

# Paso 3: Reiniciar contenedores
show_step "Reiniciando contenedores Docker..."
docker compose restart
if [ $? -eq 0 ]; then
    show_success "Contenedores reiniciados"
else
    show_error "Error al reiniciar contenedores"
    exit 1
fi

# Paso 4: Esperar a que los servicios estén listos
show_step "Esperando a que los servicios inicien (10 segundos)..."
for i in {10..1}; do
    echo -ne "${YELLOW}   ⏳ $i segundos restantes...\r${NC}"
    sleep 1
done
echo -ne '\n'
show_success "Servicios iniciados"

# Paso 5: Verificar que MySQL está listo
show_step "Verificando conexión a MySQL..."
MYSQL_READY=0
for i in {1..10}; do
    docker exec $CONTAINER_MYSQL mysqladmin ping -h localhost --silent 2>/dev/null
    if [ $? -eq 0 ]; then
        MYSQL_READY=1
        break
    fi
    sleep 2
done

if [ $MYSQL_READY -eq 1 ]; then
    show_success "MySQL está listo"
else
    show_error "MySQL no responde. Revisa los logs con: docker logs $CONTAINER_MYSQL"
fi

# Paso 6: Limpiar cache de Laravel
show_step "Limpiando cache de Laravel..."
docker exec $CONTAINER_APP php artisan config:clear 2>/dev/null
docker exec $CONTAINER_APP php artisan cache:clear 2>/dev/null
docker exec $CONTAINER_APP php artisan view:clear 2>/dev/null
show_success "Cache limpiado"

# Paso 7: Verificar estado de los contenedores
show_step "Estado final de los contenedores:"
docker compose ps
echo ""

# Paso 8: Verificar conexión a la base de datos
show_step "Verificando conexión a la base de datos..."
DB_TEST=$(docker exec $CONTAINER_APP php artisan tinker --execute="try { DB::connection()->getPdo(); echo 'OK'; } catch (Exception \$e) { echo 'FAIL'; }" 2>/dev/null | grep -o "OK")

if [ "$DB_TEST" == "OK" ]; then
    show_success "Conexión a base de datos: OK"
else
    show_error "Conexión a base de datos: FAIL"
fi

# Paso 9: Mostrar información útil
echo ""
echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   ✅ APLICACIÓN REINICIADA EXITOSAMENTE   ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}📊 Información útil:${NC}"
echo -e "   🌐 URL Local: ${GREEN}http://localhost:8000${NC}"
echo -e "   📦 Contenedores activos: ${GREEN}$(docker compose ps --services --filter "status=running" | wc -l)${NC}"
echo ""
echo -e "${YELLOW}🔧 Comandos útiles:${NC}"
echo -e "   • Ver logs:        ${CYAN}docker logs -f $CONTAINER_APP${NC}"
echo -e "   • Estado MySQL:    ${CYAN}docker exec $CONTAINER_MYSQL mysqladmin ping${NC}"
echo -e "   • Artisan tinker:  ${CYAN}docker exec -it $CONTAINER_APP php artisan tinker${NC}"
echo ""
