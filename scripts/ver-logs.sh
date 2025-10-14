#!/bin/bash

# Script para ver logs en tiempo real
# Muestra logs de diferentes contenedores Docker

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

# Nombres de contenedores
CONTAINER_APP="api-laravel-1-app"
CONTAINER_NGINX="api-laravel-1-nginx"
CONTAINER_MYSQL="api-laravel-1-mysql"
CONTAINER_REDIS="api-laravel-1-redis"

# Función para mostrar el menú
show_menu() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║       📊 VISOR DE LOGS - LARAVEL API      ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Selecciona qué logs quieres ver:${NC}"
    echo ""
    echo -e "  ${GREEN}1.${NC} Laravel App (PHP-FPM)"
    echo -e "  ${GREEN}2.${NC} Nginx (Web Server)"
    echo -e "  ${GREEN}3.${NC} MySQL (Base de datos)"
    echo -e "  ${GREEN}4.${NC} Redis (Cache)"
    echo -e "  ${GREEN}5.${NC} Todos los contenedores"
    echo ""
    echo -e "  ${BLUE}6.${NC} Laravel logs (storage/logs/laravel.log)"
    echo -e "  ${BLUE}7.${NC} Logs de errores de Laravel"
    echo -e "  ${BLUE}8.${NC} Últimas 50 líneas de Laravel"
    echo ""
    echo -e "  ${YELLOW}9.${NC} Buscar en logs de Laravel"
    echo ""
    echo -e "  ${RED}0.${NC} Salir"
    echo ""
    echo -ne "${CYAN}Opción:${NC} "
}

# Función para ver logs de Docker
view_docker_logs() {
    local container=$1
    local name=$2
    
    echo -e "${BLUE}📋 Mostrando logs de ${name}...${NC}"
    echo -e "${YELLOW}Presiona Ctrl+C para detener${NC}"
    echo ""
    sleep 1
    
    sudo docker logs -f --tail 100 $container
}

# Función para ver logs de Laravel desde el archivo
view_laravel_file_logs() {
    echo -e "${BLUE}📋 Mostrando logs de Laravel (archivo)...${NC}"
    echo -e "${YELLOW}Presiona Ctrl+C para detener${NC}"
    echo ""
    sleep 1
    
    sudo docker exec -it $CONTAINER_APP tail -f /var/www/storage/logs/laravel.log
}

# Función para ver logs de errores de Laravel
view_laravel_errors() {
    echo -e "${BLUE}📋 Mostrando solo ERRORES de Laravel...${NC}"
    echo -e "${YELLOW}Presiona Ctrl+C para detener${NC}"
    echo ""
    sleep 1
    
    sudo docker exec -it $CONTAINER_APP tail -f /var/www/storage/logs/laravel.log | grep -i "error\|exception\|fatal"
}

# Función para ver últimas líneas de Laravel
view_laravel_last() {
    echo -e "${BLUE}📋 Últimas 50 líneas de logs de Laravel:${NC}"
    echo ""
    
    sudo docker exec -it $CONTAINER_APP tail -50 /var/www/storage/logs/laravel.log
    
    echo ""
    read -p "Presiona Enter para volver al menú..."
}

# Función para buscar en logs
search_in_logs() {
    echo -e "${BLUE}🔍 Buscar en logs de Laravel${NC}"
    echo ""
    read -p "Ingresa el término de búsqueda: " search_term
    
    if [ -z "$search_term" ]; then
        echo -e "${RED}No ingresaste ningún término${NC}"
        sleep 2
        return
    fi
    
    echo ""
    echo -e "${YELLOW}Buscando '${search_term}'...${NC}"
    echo ""
    
    sudo docker exec -it $CONTAINER_APP grep -i "$search_term" /var/www/storage/logs/laravel.log | tail -50
    
    echo ""
    read -p "Presiona Enter para volver al menú..."
}

# Función para ver todos los logs
view_all_logs() {
    echo -e "${BLUE}📋 Mostrando logs de TODOS los contenedores...${NC}"
    echo -e "${YELLOW}Presiona Ctrl+C para detener${NC}"
    echo ""
    sleep 1
    
    sudo docker compose logs -f --tail 50
}

# Loop principal
while true; do
    show_menu
    read -r option
    
    case $option in
        1)
            view_docker_logs $CONTAINER_APP "Laravel App"
            ;;
        2)
            view_docker_logs $CONTAINER_NGINX "Nginx"
            ;;
        3)
            view_docker_logs $CONTAINER_MYSQL "MySQL"
            ;;
        4)
            view_docker_logs $CONTAINER_REDIS "Redis"
            ;;
        5)
            view_all_logs
            ;;
        6)
            view_laravel_file_logs
            ;;
        7)
            view_laravel_errors
            ;;
        8)
            view_laravel_last
            ;;
        9)
            search_in_logs
            ;;
        0)
            echo ""
            echo -e "${GREEN}¡Hasta luego!${NC}"
            echo ""
            exit 0
            ;;
        *)
            echo ""
            echo -e "${RED}Opción inválida${NC}"
            sleep 1
            ;;
    esac
done