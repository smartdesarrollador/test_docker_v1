#!/bin/bash

# Script para monitorear estado de contenedores Docker (Entorno Local)
# Autor: Sistema Laravel API
# Fecha: $(date +%Y-%m-%d)

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Configuración para entorno LOCAL
PROJECT_DIR="/home/jeans/proyectos/laravel-docker-test/laravel"
CONTAINER_APP="laravel-app-1"
CONTAINER_NGINX="laravel-nginx-1"
CONTAINER_MYSQL="laravel-mysql-1"
CONTAINER_REDIS="laravel-redis-1"

# Función para obtener estado del contenedor
get_container_status() {
    local container=$1
    if docker ps --filter "name=$container" --format "{{.Status}}" | grep -q "Up"; then
        echo -e "${GREEN}●${NC} Running"
    elif docker ps -a --filter "name=$container" --format "{{.Status}}" | grep -q "Exited"; then
        echo -e "${RED}●${NC} Stopped"
    else
        echo -e "${YELLOW}●${NC} Not found"
    fi
}

# Función para obtener uptime del contenedor
get_container_uptime() {
    local container=$1
    docker ps --filter "name=$container" --format "{{.Status}}" 2>/dev/null | sed 's/Up //'
}

# Función para obtener health del contenedor
get_container_health() {
    local container=$1
    local health=$(docker inspect --format='{{.State.Health.Status}}' $container 2>/dev/null)

    if [ "$health" = "healthy" ]; then
        echo -e "${GREEN}✓ Healthy${NC}"
    elif [ "$health" = "unhealthy" ]; then
        echo -e "${RED}✗ Unhealthy${NC}"
    elif [ "$health" = "starting" ]; then
        echo -e "${YELLOW}⟳ Starting${NC}"
    else
        echo -e "${CYAN}- No healthcheck${NC}"
    fi
}

# Función para mostrar el menú principal
show_menu() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║   📊 ESTADO DE CONTENEDORES - LOCAL       ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Selecciona una opción:${NC}"
    echo ""
    echo -e "  ${GREEN}1.${NC} Dashboard completo"
    echo -e "  ${GREEN}2.${NC} Estado resumido"
    echo -e "  ${GREEN}3.${NC} Uso de recursos (CPU/RAM)"
    echo -e "  ${GREEN}4.${NC} Detalles de contenedor específico"
    echo ""
    echo -e "  ${BLUE}5.${NC} Ver redes Docker"
    echo -e "  ${BLUE}6.${NC} Ver volúmenes"
    echo -e "  ${BLUE}7.${NC} Ver imágenes"
    echo ""
    echo -e "  ${MAGENTA}8.${NC} Reiniciar contenedor"
    echo -e "  ${MAGENTA}9.${NC} Reiniciar todos"
    echo -e "  ${MAGENTA}10.${NC} Monitoreo en tiempo real"
    echo ""
    echo -e "  ${RED}0.${NC} Salir"
    echo ""
    echo -ne "${CYAN}Opción:${NC} "
}

# Función para dashboard completo
show_dashboard() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              📊 DASHBOARD DE CONTENEDORES - LOCAL                 ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Fecha y hora actual
    echo -e "${YELLOW}🕐 Fecha:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "${YELLOW}🌐 Host:${NC} $(hostname)"
    echo ""

    # Laravel App
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📱 Laravel Application${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "   Contenedor:  ${YELLOW}$CONTAINER_APP${NC}"
    echo -e "   Estado:      $(get_container_status $CONTAINER_APP)"
    echo -e "   Uptime:      $(get_container_uptime $CONTAINER_APP)"
    echo -e "   Health:      $(get_container_health $CONTAINER_APP)"
    echo -e "   IP:          $(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_APP 2>/dev/null || echo 'N/A')"
    echo -e "   Puerto:      9000"
    echo ""

    # Nginx
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}🌐 Nginx Web Server${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "   Contenedor:  ${YELLOW}$CONTAINER_NGINX${NC}"
    echo -e "   Estado:      $(get_container_status $CONTAINER_NGINX)"
    echo -e "   Uptime:      $(get_container_uptime $CONTAINER_NGINX)"
    echo -e "   Health:      $(get_container_health $CONTAINER_NGINX)"
    echo -e "   IP:          $(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NGINX 2>/dev/null || echo 'N/A')"
    echo -e "   Puerto:      80 -> 8000"
    echo ""

    # MySQL
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}🗄️  MySQL Database${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "   Contenedor:  ${YELLOW}$CONTAINER_MYSQL${NC}"
    echo -e "   Estado:      $(get_container_status $CONTAINER_MYSQL)"
    echo -e "   Uptime:      $(get_container_uptime $CONTAINER_MYSQL)"
    echo -e "   Health:      $(get_container_health $CONTAINER_MYSQL)"
    echo -e "   IP:          $(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_MYSQL 2>/dev/null || echo 'N/A')"
    echo -e "   Puerto:      3306"
    echo -e "   Base de datos: ${CYAN}laravel${NC}"
    echo ""

    # Redis
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}⚡ Redis Cache${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "   Contenedor:  ${YELLOW}$CONTAINER_REDIS${NC}"
    echo -e "   Estado:      $(get_container_status $CONTAINER_REDIS)"
    echo -e "   Uptime:      $(get_container_uptime $CONTAINER_REDIS)"
    echo -e "   Health:      $(get_container_health $CONTAINER_REDIS)"
    echo -e "   IP:          $(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_REDIS 2>/dev/null || echo 'N/A')"
    echo -e "   Puerto:      6379"
    echo ""

    # Resumen
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📈 Resumen${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    running=$(docker ps | grep -c "laravel-" || echo 0)
    total=$(docker ps -a | grep -c "laravel-" || echo 0)

    echo -e "   Contenedores corriendo: ${GREEN}$running${NC}/$total"
    echo -e "   Red:                     ${CYAN}laravel_default${NC}"
    echo -e "   URL Local:               ${CYAN}http://localhost:8000${NC}"
    echo ""

    read -p "Presiona Enter para continuar..."
}

# Función para estado resumido
show_summary() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║         📋 ESTADO RESUMIDO                ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo ""

    cd $PROJECT_DIR && docker compose ps

    echo ""
    read -p "Presiona Enter para continuar..."
}

# Función para uso de recursos
show_resources() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║      💻 USO DE RECURSOS (CPU/RAM)        ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Actualizando cada 2 segundos... (Ctrl+C para salir)${NC}"
    echo ""

    docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}" \
        $CONTAINER_APP $CONTAINER_NGINX $CONTAINER_MYSQL $CONTAINER_REDIS
}

# Función para detalles de contenedor específico
show_container_details() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     📦 DETALLES DE CONTENEDOR             ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Selecciona el contenedor:${NC}"
    echo ""
    echo -e "  ${GREEN}1.${NC} Laravel App"
    echo -e "  ${GREEN}2.${NC} Nginx"
    echo -e "  ${GREEN}3.${NC} MySQL"
    echo -e "  ${GREEN}4.${NC} Redis"
    echo ""
    read -p "Opción: " container_choice

    case $container_choice in
        1) selected=$CONTAINER_APP ;;
        2) selected=$CONTAINER_NGINX ;;
        3) selected=$CONTAINER_MYSQL ;;
        4) selected=$CONTAINER_REDIS ;;
        *)
            echo -e "${RED}Opción inválida${NC}"
            sleep 2
            return
            ;;
    esac

    clear
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     📦 DETALLES: $selected${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo ""

    docker inspect $selected --format='
{{println "🏷️  INFORMACIÓN GENERAL"}}
{{println "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"}}
Nombre:       {{.Name}}
ID:           {{.Id}}
Imagen:       {{.Config.Image}}
Estado:       {{.State.Status}}
PID:          {{.State.Pid}}
Creado:       {{.Created}}
Iniciado:     {{.State.StartedAt}}

{{println ""}}
{{println "🌐 RED"}}
{{println "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"}}
{{range $network, $config := .NetworkSettings.Networks}}
Red:          {{$network}}
IP:           {{$config.IPAddress}}
Gateway:      {{$config.Gateway}}
MAC:          {{$config.MacAddress}}
{{end}}

{{println ""}}
{{println "💾 VOLÚMENES"}}
{{println "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"}}
{{range .Mounts}}
Tipo:         {{.Type}}
Source:       {{.Source}}
Destination:  {{.Destination}}
{{end}}

{{println ""}}
{{println "🔧 CONFIGURACIÓN"}}
{{println "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"}}
Restart:      {{.HostConfig.RestartPolicy.Name}}
'

    echo ""
    read -p "Presiona Enter para continuar..."
}

# Función para ver redes
show_networks() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║          🌐 REDES DOCKER                  ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo ""

    docker network ls

    echo ""
    echo -e "${YELLOW}Detalles de la red 'laravel_default':${NC}"
    echo ""

    docker network inspect laravel_default --format='
Nombre:       {{.Name}}
ID:           {{.Id}}
Driver:       {{.Driver}}
Subnet:       {{range .IPAM.Config}}{{.Subnet}}{{end}}
Gateway:      {{range .IPAM.Config}}{{.Gateway}}{{end}}

Contenedores conectados:
{{range $container, $config := .Containers}}
  - {{$config.Name}} ({{$config.IPv4Address}})
{{end}}
' 2>/dev/null

    echo ""
    read -p "Presiona Enter para continuar..."
}

# Función para ver volúmenes
show_volumes() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║         💾 VOLÚMENES DOCKER               ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo ""

    docker volume ls

    echo ""
    echo -e "${YELLOW}Detalles del volumen de MySQL:${NC}"
    echo ""

    docker volume inspect laravel_mysql_data --format='
Nombre:       {{.Name}}
Driver:       {{.Driver}}
Mountpoint:   {{.Mountpoint}}
Creado:       {{.CreatedAt}}
' 2>/dev/null

    echo ""
    read -p "Presiona Enter para continuar..."
}

# Función para ver imágenes
show_images() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║         📀 IMÁGENES DOCKER                ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo ""

    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}"

    echo ""
    echo -e "${YELLOW}Espacio total usado por imágenes:${NC}"
    docker system df | grep Images

    echo ""
    read -p "Presiona Enter para continuar..."
}

# Función para reiniciar contenedor
restart_container() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     🔄 REINICIAR CONTENEDOR               ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Selecciona el contenedor:${NC}"
    echo ""
    echo -e "  ${GREEN}1.${NC} Laravel App"
    echo -e "  ${GREEN}2.${NC} Nginx"
    echo -e "  ${GREEN}3.${NC} MySQL"
    echo -e "  ${GREEN}4.${NC} Redis"
    echo ""
    read -p "Opción: " container_choice

    case $container_choice in
        1) selected=$CONTAINER_APP; name="Laravel App" ;;
        2) selected=$CONTAINER_NGINX; name="Nginx" ;;
        3) selected=$CONTAINER_MYSQL; name="MySQL" ;;
        4) selected=$CONTAINER_REDIS; name="Redis" ;;
        *)
            echo -e "${RED}Opción inválida${NC}"
            sleep 2
            return
            ;;
    esac

    echo ""
    echo -e "${YELLOW}⏳ Reiniciando $name...${NC}"
    docker restart $selected

    echo -e "${GREEN}✅ $name reiniciado${NC}"
    sleep 2
}

# Función para reiniciar todos
restart_all() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     🔄 REINICIAR TODOS                    ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${RED}⚠️  Esto reiniciará todos los contenedores${NC}"
    read -p "¿Estás seguro? (y/n): " confirm

    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Operación cancelada${NC}"
        sleep 2
        return
    fi

    echo ""
    cd $PROJECT_DIR
    echo -e "${YELLOW}⏳ Reiniciando contenedores...${NC}"
    docker compose restart

    echo ""
    echo -e "${GREEN}✅ Todos los contenedores reiniciados${NC}"
    sleep 2
}

# Función para monitoreo en tiempo real
monitor_realtime() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     📊 MONITOREO EN TIEMPO REAL           ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Presiona 'q' para salir${NC}"
    echo ""
    sleep 2

    cd $PROJECT_DIR && docker compose top
}

# Loop principal
while true; do
    show_menu
    read -r option

    case $option in
        1) show_dashboard ;;
        2) show_summary ;;
        3) show_resources ;;
        4) show_container_details ;;
        5) show_networks ;;
        6) show_volumes ;;
        7) show_images ;;
        8) restart_container ;;
        9) restart_all ;;
        10) monitor_realtime ;;
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
