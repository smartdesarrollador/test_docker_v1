#!/bin/bash

# Script para backup y restauración de MySQL
# Autor: Sistema Laravel API
# Fecha: $(date +%Y-%m-%d)

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

# Configuración
CONTAINER_MYSQL="api-laravel-1-mysql"
DB_NAME="laravel"
DB_USER="laravel"
DB_PASSWORD="PeruadmLima25$"
BACKUP_DIR="$HOME/backups/mysql"
LOG_FILE="$BACKUP_DIR/backup.log"

# Crear directorio de backups si no existe
mkdir -p $BACKUP_DIR

# Función para registrar en log
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

# Función para mostrar el menú
show_menu() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     💾 BACKUP DE BASE DE DATOS MYSQL      ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}¿Qué deseas hacer?${NC}"
    echo ""
    echo -e "  ${GREEN}1.${NC} Crear backup ahora"
    echo -e "  ${GREEN}2.${NC} Ver backups existentes"
    echo -e "  ${GREEN}3.${NC} Restaurar desde backup"
    echo -e "  ${GREEN}4.${NC} Eliminar backups antiguos"
    echo -e "  ${GREEN}5.${NC} Configurar backup automático (cron)"
    echo ""
    echo -e "  ${BLUE}6.${NC} Ver espacio en disco"
    echo -e "  ${BLUE}7.${NC} Ver log de backups"
    echo ""
    echo -e "  ${RED}0.${NC} Salir"
    echo ""
    echo -ne "${CYAN}Opción:${NC} "
}

# Función para crear backup
create_backup() {
    echo ""
    echo -e "${BLUE}📦 Creando backup de la base de datos...${NC}"
    echo ""
    
    # Nombre del archivo con fecha y hora
    BACKUP_FILE="backup_${DB_NAME}_$(date +%Y%m%d_%H%M%S).sql"
    BACKUP_PATH="$BACKUP_DIR/$BACKUP_FILE"
    
    # Verificar que MySQL está corriendo
    if ! sudo docker ps | grep -q $CONTAINER_MYSQL; then
        echo -e "${RED}❌ Error: El contenedor MySQL no está corriendo${NC}"
        log_message "ERROR: Contenedor MySQL no está corriendo"
        return 1
    fi
    
    # Crear backup
    echo -e "${YELLOW}⏳ Exportando base de datos...${NC}"
    sudo docker exec $CONTAINER_MYSQL mysqldump -u $DB_USER -p"$DB_PASSWORD" $DB_NAME > $BACKUP_PATH 2>/dev/null
    
    if [ $? -eq 0 ]; then
        # Comprimir el backup
        echo -e "${YELLOW}⏳ Comprimiendo archivo...${NC}"
        gzip $BACKUP_PATH
        BACKUP_PATH="${BACKUP_PATH}.gz"
        
        # Calcular tamaño
        SIZE=$(du -h $BACKUP_PATH | cut -f1)
        
        echo ""
        echo -e "${GREEN}✅ Backup creado exitosamente${NC}"
        echo -e "   📁 Archivo: ${CYAN}$BACKUP_FILE.gz${NC}"
        echo -e "   📊 Tamaño: ${CYAN}$SIZE${NC}"
        echo -e "   📍 Ubicación: ${CYAN}$BACKUP_DIR${NC}"
        
        log_message "SUCCESS: Backup creado - $BACKUP_FILE.gz ($SIZE)"
    else
        echo -e "${RED}❌ Error al crear el backup${NC}"
        log_message "ERROR: Falló la creación del backup"
        return 1
    fi
    
    echo ""
    read -p "Presiona Enter para continuar..."
}

# Función para listar backups
list_backups() {
    echo ""
    echo -e "${BLUE}📋 Backups disponibles:${NC}"
    echo ""
    
    if [ ! "$(ls -A $BACKUP_DIR/*.sql.gz 2>/dev/null)" ]; then
        echo -e "${YELLOW}No hay backups disponibles${NC}"
        echo ""
        read -p "Presiona Enter para continuar..."
        return
    fi
    
    echo -e "${CYAN}#  | Archivo                           | Tamaño | Fecha${NC}"
    echo "---+------------------------------------+--------+------------------"
    
    i=1
    for backup in $(ls -t $BACKUP_DIR/*.sql.gz 2>/dev/null); do
        filename=$(basename $backup)
        size=$(du -h $backup | cut -f1)
        date=$(stat -c %y $backup | cut -d. -f1)
        printf "%-3s| %-34s | %-6s | %s\n" "$i" "$filename" "$size" "$date"
        i=$((i+1))
    done
    
    echo ""
    read -p "Presiona Enter para continuar..."
}

# Función para restaurar backup
restore_backup() {
    echo ""
    echo -e "${BLUE}🔄 Restaurar base de datos desde backup${NC}"
    echo ""
    
    if [ ! "$(ls -A $BACKUP_DIR/*.sql.gz 2>/dev/null)" ]; then
        echo -e "${YELLOW}No hay backups disponibles para restaurar${NC}"
        echo ""
        read -p "Presiona Enter para continuar..."
        return
    fi
    
    # Listar backups con números
    echo -e "${CYAN}Backups disponibles:${NC}"
    echo ""
    
    i=1
    declare -a backup_files
    for backup in $(ls -t $BACKUP_DIR/*.sql.gz 2>/dev/null); do
        filename=$(basename $backup)
        size=$(du -h $backup | cut -f1)
        date=$(stat -c %y $backup | cut -d. -f1)
        echo -e "  ${GREEN}$i.${NC} $filename ($size) - $date"
        backup_files[$i]=$backup
        i=$((i+1))
    done
    
    echo ""
    read -p "Selecciona el número del backup a restaurar (0 para cancelar): " choice
    
    if [ "$choice" = "0" ]; then
        return
    fi
    
    if [ -z "${backup_files[$choice]}" ]; then
        echo -e "${RED}Opción inválida${NC}"
        sleep 2
        return
    fi
    
    selected_backup=${backup_files[$choice]}
    
    echo ""
    echo -e "${RED}⚠️  ADVERTENCIA: Esto sobrescribirá la base de datos actual${NC}"
    read -p "¿Estás seguro? (escribe 'SI' para confirmar): " confirm
    
    if [ "$confirm" != "SI" ]; then
        echo -e "${YELLOW}Operación cancelada${NC}"
        sleep 2
        return
    fi
    
    echo ""
    echo -e "${YELLOW}⏳ Restaurando base de datos...${NC}"
    
    # Descomprimir temporalmente
    temp_file="/tmp/restore_temp.sql"
    gunzip -c $selected_backup > $temp_file
    
    # Restaurar
    sudo docker exec -i $CONTAINER_MYSQL mysql -u $DB_USER -p"$DB_PASSWORD" $DB_NAME < $temp_file 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Base de datos restaurada exitosamente${NC}"
        log_message "SUCCESS: Base de datos restaurada desde $(basename $selected_backup)"
        
        # Limpiar cache de Laravel
        echo ""
        echo -e "${YELLOW}⏳ Limpiando cache de Laravel...${NC}"
        sudo docker exec api-laravel-1-app php artisan config:clear 2>/dev/null
        sudo docker exec api-laravel-1-app php artisan cache:clear 2>/dev/null
        echo -e "${GREEN}✅ Cache limpiado${NC}"
    else
        echo -e "${RED}❌ Error al restaurar la base de datos${NC}"
        log_message "ERROR: Falló la restauración desde $(basename $selected_backup)"
    fi
    
    # Limpiar archivo temporal
    rm -f $temp_file
    
    echo ""
    read -p "Presiona Enter para continuar..."
}

# Función para eliminar backups antiguos
delete_old_backups() {
    echo ""
    echo -e "${BLUE}🗑️  Eliminar backups antiguos${NC}"
    echo ""
    
    read -p "¿Cuántos días de antigüedad? (ejemplo: 30): " days
    
    if ! [[ "$days" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Valor inválido${NC}"
        sleep 2
        return
    fi
    
    echo ""
    echo -e "${YELLOW}Buscando backups con más de $days días...${NC}"
    
    count=$(find $BACKUP_DIR -name "*.sql.gz" -mtime +$days | wc -l)
    
    if [ $count -eq 0 ]; then
        echo -e "${GREEN}No hay backups antiguos para eliminar${NC}"
    else
        echo -e "${YELLOW}Se encontraron $count backup(s) antiguos${NC}"
        read -p "¿Deseas eliminarlos? (y/n): " confirm
        
        if [[ $confirm =~ ^[Yy]$ ]]; then
            find $BACKUP_DIR -name "*.sql.gz" -mtime +$days -delete
            echo -e "${GREEN}✅ Backups antiguos eliminados${NC}"
            log_message "INFO: Eliminados $count backups con más de $days días"
        else
            echo -e "${YELLOW}Operación cancelada${NC}"
        fi
    fi
    
    echo ""
    read -p "Presiona Enter para continuar..."
}

# Función para configurar backup automático
setup_cron() {
    echo ""
    echo -e "${BLUE}⏰ Configurar backup automático (cron)${NC}"
    echo ""
    echo -e "${YELLOW}¿Con qué frecuencia deseas hacer backups?${NC}"
    echo ""
    echo "  1. Diario a las 2:00 AM"
    echo "  2. Cada 12 horas"
    echo "  3. Cada 6 horas"
    echo "  4. Semanal (Domingos 3:00 AM)"
    echo "  5. Personalizado"
    echo "  6. Desactivar backup automático"
    echo ""
    read -p "Opción: " cron_option
    
    case $cron_option in
        1)
            cron_schedule="0 2 * * *"
            description="Diario a las 2:00 AM"
            ;;
        2)
            cron_schedule="0 */12 * * *"
            description="Cada 12 horas"
            ;;
        3)
            cron_schedule="0 */6 * * *"
            description="Cada 6 horas"
            ;;
        4)
            cron_schedule="0 3 * * 0"
            description="Domingos a las 3:00 AM"
            ;;
        5)
            echo ""
            echo -e "${CYAN}Formato cron: minuto hora día mes día_semana${NC}"
            echo "Ejemplo: 0 2 * * * (2:00 AM todos los días)"
            read -p "Ingresa el schedule: " cron_schedule
            description="Personalizado: $cron_schedule"
            ;;
        6)
            # Eliminar cron job
            crontab -l 2>/dev/null | grep -v "backup-db.sh" | crontab -
            echo -e "${GREEN}✅ Backup automático desactivado${NC}"
            log_message "INFO: Backup automático desactivado"
            echo ""
            read -p "Presiona Enter para continuar..."
            return
            ;;
        *)
            echo -e "${RED}Opción inválida${NC}"
            sleep 2
            return
            ;;
    esac
    
    # Crear script de backup automático
    AUTO_SCRIPT="$BACKUP_DIR/auto-backup.sh"
    cat > $AUTO_SCRIPT << 'EOF'
#!/bin/bash
CONTAINER_MYSQL="api-laravel-1-mysql"
DB_NAME="laravel"
DB_USER="laravel"
DB_PASSWORD="PeruadmLima25$"
BACKUP_DIR="$HOME/backups/mysql"
BACKUP_FILE="backup_${DB_NAME}_$(date +%Y%m%d_%H%M%S).sql"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_FILE"

mkdir -p $BACKUP_DIR

sudo docker exec $CONTAINER_MYSQL mysqldump -u $DB_USER -p"$DB_PASSWORD" $DB_NAME > $BACKUP_PATH 2>/dev/null

if [ $? -eq 0 ]; then
    gzip $BACKUP_PATH
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup automático creado: $BACKUP_FILE.gz" >> $BACKUP_DIR/backup.log
    
    # Eliminar backups con más de 30 días
    find $BACKUP_DIR -name "*.sql.gz" -mtime +30 -delete
fi
EOF
    
    chmod +x $AUTO_SCRIPT
    
    # Agregar a crontab
    (crontab -l 2>/dev/null | grep -v "backup-db.sh"; echo "$cron_schedule $AUTO_SCRIPT >> $BACKUP_DIR/cron.log 2>&1") | crontab -
    
    echo ""
    echo -e "${GREEN}✅ Backup automático configurado${NC}"
    echo -e "   ⏰ Frecuencia: ${CYAN}$description${NC}"
    echo -e "   📁 Ubicación: ${CYAN}$BACKUP_DIR${NC}"
    echo -e "   🗑️  Retención: ${CYAN}30 días${NC}"
    
    log_message "INFO: Backup automático configurado - $description"
    
    echo ""
    read -p "Presiona Enter para continuar..."
}

# Función para ver espacio en disco
check_disk_space() {
    echo ""
    echo -e "${BLUE}💾 Espacio en disco:${NC}"
    echo ""
    
    df -h $HOME | awk 'NR==1 {print "Filesystem      Size  Used Avail Use% Mounted"} NR==2 {print}'
    
    echo ""
    echo -e "${BLUE}📊 Espacio usado por backups:${NC}"
    du -sh $BACKUP_DIR 2>/dev/null || echo "0"
    
    echo ""
    echo -e "${BLUE}📁 Cantidad de backups:${NC}"
    ls -1 $BACKUP_DIR/*.sql.gz 2>/dev/null | wc -l
    
    echo ""
    read -p "Presiona Enter para continuar..."
}

# Función para ver log
view_log() {
    echo ""
    echo -e "${BLUE}📋 Últimas 30 líneas del log:${NC}"
    echo ""
    
    if [ -f $LOG_FILE ]; then
        tail -30 $LOG_FILE
    else
        echo -e "${YELLOW}No hay registros en el log${NC}"
    fi
    
    echo ""
    read -p "Presiona Enter para continuar..."
}

# Loop principal
while true; do
    show_menu
    read -r option
    
    case $option in
        1) create_backup ;;
        2) list_backups ;;
        3) restore_backup ;;
        4) delete_old_backups ;;
        5) setup_cron ;;
        6) check_disk_space ;;
        7) view_log ;;
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