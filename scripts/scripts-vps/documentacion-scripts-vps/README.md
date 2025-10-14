# Documentación de Scripts VPS

Esta documentación describe los scripts de administración y mantenimiento para la aplicación Laravel API desplegada en VPS con Docker.

---

## Índice

1. [backup-db.sh](#backup-dbsh) - Backup y restauración de MySQL
2. [deploy.sh](#deploysh) - Deploy automático desde Git
3. [estado-contenedores.sh](#estado-contenedoressh) - Monitoreo de contenedores Docker
4. [limpiar-cache.sh](#limpiar-cachesh) - Limpieza de cache de Laravel
5. [reiniciar-app.sh](#reiniciar-appsh) - Reinicio completo de la aplicación
6. [ver-logs.sh](#ver-logssh) - Visor de logs interactivo

---

## backup-db.sh

**Ubicación:** `scripts/scripts-vps/backup-db.sh`

### Descripción
Script interactivo para backup y restauración de la base de datos MySQL. Permite crear backups manuales o automáticos (cron), restaurar desde backups, y gestionar archivos de backup antiguos.

### Características principales
- **Backup manual**: Crea backup comprimido (.sql.gz) con timestamp
- **Listado de backups**: Muestra todos los backups disponibles con tamaño y fecha
- **Restauración**: Permite restaurar la BD desde cualquier backup
- **Limpieza automática**: Elimina backups antiguos por días
- **Backup automático (cron)**: Configura backups programados
- **Monitoreo**: Muestra espacio en disco y logs de backup

### Configuración
```bash
CONTAINER_MYSQL="api-laravel-1-mysql"
DB_NAME="laravel"
DB_USER="laravel"
DB_PASSWORD="PeruadmLima25$"
BACKUP_DIR="$HOME/backups/mysql"
```

### Uso
```bash
bash backup-db.sh
```

### Menú de opciones
1. **Crear backup ahora** - Genera backup manual inmediato
2. **Ver backups existentes** - Lista todos los backups con información
3. **Restaurar desde backup** - Selecciona y restaura un backup (requiere confirmación)
4. **Eliminar backups antiguos** - Elimina backups con más de X días
5. **Configurar backup automático (cron)** - Configura backups programados:
   - Diario a las 2:00 AM
   - Cada 12 horas
   - Cada 6 horas
   - Semanal (Domingos 3:00 AM)
   - Personalizado
6. **Ver espacio en disco** - Muestra uso de disco y cantidad de backups
7. **Ver log de backups** - Muestra últimas 30 líneas del log

### Características adicionales
- Los backups se comprimen automáticamente con gzip
- La restauración limpia automáticamente el cache de Laravel
- Los backups automáticos eliminan archivos con más de 30 días
- Log detallado de todas las operaciones

### Archivos generados
- `$HOME/backups/mysql/backup_laravel_YYYYMMDD_HHMMSS.sql.gz` - Archivos de backup
- `$HOME/backups/mysql/backup.log` - Log de operaciones
- `$HOME/backups/mysql/auto-backup.sh` - Script de backup automático (si se configura)
- `$HOME/backups/mysql/cron.log` - Log de ejecuciones cron

---

## deploy.sh

**Ubicación:** `scripts/scripts-vps/deploy.sh`

### Descripción
Script para automatizar el proceso de deploy desde Git. Sincroniza código, limpia cache, ejecuta migraciones y reinicia contenedores según sea necesario.

### Características principales
- Pull automático desde Git (branch main)
- Stash de cambios locales si existen
- Opciones interactivas para:
  - Limpiar cache de Laravel
  - Ejecutar migraciones
  - Reiniciar contenedores

### Configuración
```bash
PROJECT_DIR="$HOME/proyectos/proyecto-1/api-laravel-1"
BRANCH="main"
```

### Uso
```bash
bash deploy.sh
```

### Flujo de ejecución
1. Navega al directorio del proyecto
2. Muestra el branch actual
3. Guarda cambios locales (git stash) si existen
4. Ejecuta `git pull origin main`
5. Pregunta si limpiar cache (config, cache, views)
6. Pregunta si ejecutar migraciones con `--force`
7. Pregunta si reiniciar contenedores (app y nginx)
8. Muestra URL de la API al finalizar

### Comandos Laravel ejecutados (opcionales)
```bash
php artisan config:clear
php artisan cache:clear
php artisan view:clear
php artisan migrate --force
```

### URL de la aplicación
```
https://api.smartdigitaltec.com
```

---

## estado-contenedores.sh

**Ubicación:** `scripts/scripts-vps/estado-contenedores.sh`

### Descripción
Dashboard interactivo completo para monitorear el estado de todos los contenedores Docker de la aplicación Laravel. Proporciona información detallada sobre salud, recursos, redes y volúmenes.

### Contenedores monitoreados
- `api-laravel-1-app` - Aplicación Laravel (PHP-FPM)
- `api-laravel-1-nginx` - Servidor web Nginx
- `api-laravel-1-mysql` - Base de datos MySQL
- `api-laravel-1-redis` - Cache Redis

### Uso
```bash
bash estado-contenedores.sh
```

### Menú principal

#### Opciones de monitoreo
1. **Dashboard completo** - Vista detallada de todos los contenedores con:
   - Estado (Running/Stopped/Not found)
   - Uptime
   - Health status
   - IP interna
   - Puertos expuestos
   - Resumen general

2. **Estado resumido** - Vista rápida con `docker compose ps`

3. **Uso de recursos (CPU/RAM)** - Monitoreo en tiempo real con:
   - Porcentaje de CPU
   - Uso de memoria (RAM)
   - Porcentaje de memoria
   - Network I/O
   - Block I/O
   - Actualización cada 2 segundos

4. **Detalles de contenedor específico** - Información detallada de un contenedor:
   - Información general (nombre, ID, imagen, estado, PID)
   - Configuración de red (IP, gateway, MAC)
   - Volúmenes montados
   - Políticas de reinicio

#### Opciones de infraestructura
5. **Ver redes Docker** - Lista todas las redes y detalles de la red 'global'
6. **Ver volúmenes** - Muestra volúmenes y espacio usado por MySQL
7. **Ver imágenes** - Lista imágenes Docker y espacio total usado

#### Opciones de gestión
8. **Reiniciar contenedor** - Reinicia un contenedor específico
9. **Reiniciar todos** - Reinicia todos los contenedores (requiere confirmación)
10. **Monitoreo en tiempo real** - Vista de procesos con `docker compose top`

### Información mostrada

#### Por contenedor
- **Estado**: Running (verde), Stopped (rojo), Not found (amarillo)
- **Uptime**: Tiempo que lleva corriendo
- **Health**: Healthy, Unhealthy, Starting, o sin healthcheck
- **IP**: Dirección IP en la red Docker
- **Puerto**: Puerto del servicio

#### Red 'global'
```
Driver:   bridge
Subnet:   172.x.x.x/16
Gateway:  172.x.x.x
```

#### Volúmenes
- Volumen de MySQL: `api-laravel-1_mysql_data`
- Espacio usado por volumen

---

## limpiar-cache.sh

**Ubicación:** `scripts/scripts-vps/limpiar-cache.sh`

### Descripción
Script simple para limpiar todos los tipos de cache de Laravel. Ejecuta comandos artisan de limpieza en el contenedor Docker.

### Características
- Limpieza de configuración
- Limpieza de cache de aplicación
- Limpieza de cache de rutas
- Limpieza de vistas compiladas
- Limpieza de eventos cacheados
- Optimización del autoloader de Composer

### Configuración
```bash
CONTAINER_NAME="api-laravel-1-app"
```

### Uso
```bash
bash limpiar-cache.sh
```

### Comandos ejecutados
```bash
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear
php artisan event:clear
composer dump-autoload -o
```

### Salida
El script muestra cada comando ejecutado con:
- Indicador visual de progreso (→)
- Confirmación de éxito (✓) o error (✗)
- Resumen final

---

## reiniciar-app.sh

**Ubicación:** `scripts/scripts-vps/reiniciar-app.sh`

### Descripción
Script completo para reiniciar toda la aplicación Laravel. Reinicia contenedores Docker, espera a que estén listos, verifica conexiones y limpia cache.

### Características principales
- Reinicio ordenado de todos los contenedores
- Espera inteligente para que servicios inicien
- Verificación de estado de MySQL
- Limpieza automática de cache
- Verificación de conexión a base de datos
- Información útil al finalizar

### Configuración
```bash
PROJECT_DIR="$HOME/proyectos/proyecto-1/api-laravel-1"
CONTAINER_APP="api-laravel-1-app"
CONTAINER_NGINX="api-laravel-1-nginx"
CONTAINER_MYSQL="api-laravel-1-mysql"
CONTAINER_REDIS="api-laravel-1-redis"
```

### Uso
```bash
bash reiniciar-app.sh
```

### Proceso de reinicio (9 pasos)

1. **Navegación**: Navega al directorio del proyecto
2. **Verificación inicial**: Muestra estado actual con `docker compose ps`
3. **Reinicio**: Reinicia todos los contenedores con `docker compose restart`
4. **Espera**: Countdown de 15 segundos para inicio de servicios
5. **Verificación MySQL**: Intenta conectar a MySQL (hasta 10 intentos)
6. **Limpieza de cache**: Ejecuta comandos artisan de limpieza
7. **Estado final**: Muestra estado de contenedores
8. **Test de conexión BD**: Verifica conexión con tinker
9. **Información útil**: Muestra URL, contenedores activos y comandos útiles

### Verificaciones
- **MySQL ping**: Verifica que MySQL esté respondiendo
- **Test de conexión BD**: Usa Laravel Tinker para verificar conexión PDO

### Información final
```
URL: https://api.smartdigitaltec.com
Contenedores activos: X/4
```

### Comandos útiles mostrados
```bash
# Ver logs
sudo docker logs -f api-laravel-1-app

# Estado MySQL
sudo docker exec -it api-laravel-1-mysql mysqladmin ping

# Artisan tinker
sudo docker exec -it api-laravel-1-app php artisan tinker
```

---

## ver-logs.sh

**Ubicación:** `scripts/scripts-vps/ver-logs.sh`

### Descripción
Visor interactivo de logs para todos los contenedores Docker y logs de Laravel. Permite ver logs en tiempo real, buscar errores y filtrar información.

### Uso
```bash
bash ver-logs.sh
```

### Menú de opciones

#### Logs de contenedores Docker (tiempo real)
1. **Laravel App (PHP-FPM)** - Logs del contenedor de aplicación
2. **Nginx (Web Server)** - Logs del servidor web
3. **MySQL (Base de datos)** - Logs de MySQL
4. **Redis (Cache)** - Logs de Redis
5. **Todos los contenedores** - Logs combinados de todos los servicios

#### Logs de Laravel (archivo storage/logs/laravel.log)
6. **Laravel logs** - Seguimiento en tiempo real del archivo de log
7. **Logs de errores de Laravel** - Filtra solo líneas con ERROR, EXCEPTION o FATAL
8. **Últimas 50 líneas de Laravel** - Vista rápida de logs recientes

#### Búsqueda
9. **Buscar en logs de Laravel** - Busca término específico y muestra últimas 50 coincidencias

### Características
- **Tiempo real**: Usa `tail -f` para seguimiento continuo
- **Filtrado**: Opción para ver solo errores
- **Búsqueda**: Búsqueda case-insensitive con grep
- **Últimas N líneas**: Muestra cantidad configurable de líneas (default: 50-100)

### Comandos ejecutados

#### Logs de Docker
```bash
sudo docker logs -f --tail 100 <container>
sudo docker compose logs -f --tail 50
```

#### Logs de Laravel
```bash
# Tiempo real
sudo docker exec -it api-laravel-1-app tail -f /var/www/storage/logs/laravel.log

# Solo errores
sudo docker exec -it api-laravel-1-app tail -f /var/www/storage/logs/laravel.log | grep -i "error|exception|fatal"

# Últimas líneas
sudo docker exec -it api-laravel-1-app tail -50 /var/www/storage/logs/laravel.log

# Búsqueda
sudo docker exec -it api-laravel-1-app grep -i "término" /var/www/storage/logs/laravel.log | tail -50
```

### Casos de uso
- **Debug de errores**: Ver errores en tiempo real mientras se prueba la aplicación
- **Monitoreo de producción**: Seguimiento de logs de Nginx y aplicación
- **Troubleshooting BD**: Ver logs de MySQL para problemas de conexión
- **Análisis post-error**: Buscar términos específicos en logs históricos

---

## Requisitos generales

### Sistema operativo
- Linux (probado en Ubuntu/Debian)
- Bash shell

### Software requerido
- Docker y Docker Compose
- Git
- Permisos sudo para comandos Docker

### Estructura de directorios esperada
```
$HOME/
├── proyectos/
│   └── proyecto-1/
│       └── api-laravel-1/          # Proyecto Laravel
│           ├── docker-compose.yml
│           └── ...
└── backups/
    └── mysql/                       # Backups de BD (auto-creado)
```

---

## Mejores prácticas

### Backups
- Ejecutar backup antes de deploys importantes
- Configurar backup automático diario
- Mantener al menos 7-30 días de backups
- Verificar espacio en disco regularmente

### Deploy
- Siempre revisar el branch antes de hacer pull
- Ejecutar migraciones en horarios de bajo tráfico
- Limpiar cache después de cambios en configuración
- Verificar logs después del deploy

### Monitoreo
- Revisar estado de contenedores regularmente
- Monitorear uso de recursos (CPU/RAM)
- Verificar salud de contenedores con healthchecks
- Revisar logs de errores periódicamente

### Mantenimiento
- Limpiar cache después de cambios de configuración
- Reiniciar aplicación solo cuando sea necesario
- Verificar conexión a BD después de reinicios
- Revisar logs después de operaciones críticas

---

## Solución de problemas comunes

### Contenedor no inicia
```bash
# Verificar estado
bash estado-contenedores.sh (opción 1)

# Ver logs del contenedor
bash ver-logs.sh

# Reiniciar contenedor específico
bash estado-contenedores.sh (opción 8)
```

### Error de conexión a base de datos
```bash
# Verificar MySQL
sudo docker exec -it api-laravel-1-mysql mysqladmin ping

# Ver logs de MySQL
bash ver-logs.sh (opción 3)

# Reiniciar con verificación
bash reiniciar-app.sh
```

### Error después de deploy
```bash
# Limpiar cache
bash limpiar-cache.sh

# Verificar logs
bash ver-logs.sh (opción 7 para errores)

# Si persiste, restaurar backup
bash backup-db.sh (opción 3)
```

### Espacio en disco lleno
```bash
# Verificar espacio de backups
bash backup-db.sh (opción 6)

# Eliminar backups antiguos
bash backup-db.sh (opción 4)

# Verificar volúmenes Docker
bash estado-contenedores.sh (opción 6)
```

---

## Seguridad

### Consideraciones importantes
- Los scripts contienen credenciales en texto plano (`DB_PASSWORD`)
- Se recomienda usar variables de entorno para credenciales
- Limitar permisos de los scripts: `chmod 700 *.sh`
- Proteger el directorio de backups: `chmod 700 ~/backups`
- No compartir logs que puedan contener información sensible

### Recomendaciones
```bash
# Cambiar permisos de scripts
chmod 700 /path/to/scripts/*.sh

# Proteger directorio de backups
chmod 700 ~/backups/mysql

# Usar variables de entorno (ejemplo)
export DB_PASSWORD="tu-password-seguro"
```

---

## Automatización con Cron

### Ejemplos de configuración cron

```bash
# Editar crontab
crontab -e

# Backup diario a las 2 AM
0 2 * * * /home/user/scripts/scripts-vps/backup-db.sh auto >> /var/log/backup.log 2>&1

# Limpiar cache diariamente a las 4 AM
0 4 * * * /home/user/scripts/scripts-vps/limpiar-cache.sh >> /var/log/cache-clean.log 2>&1

# Monitoreo cada hora
0 * * * * /home/user/scripts/scripts-vps/estado-contenedores.sh check >> /var/log/monitor.log 2>&1
```

**Nota**: El script `backup-db.sh` tiene su propio configurador de cron integrado (opción 5).

---

## Contacto y soporte

Para reportar problemas o sugerencias sobre estos scripts, contactar al equipo de desarrollo.

**URL de la aplicación**: https://api.smartdigitaltec.com

---

## Changelog

### Versión actual
- Scripts completos y funcionales para:
  - Backup/restauración de BD
  - Deploy automático
  - Monitoreo de contenedores
  - Gestión de cache
  - Reinicio de aplicación
  - Visualización de logs

### Mejoras futuras sugeridas
- [ ] Parametrizar credenciales vía variables de entorno
- [ ] Agregar notificaciones por email/Slack
- [ ] Implementar health checks automáticos
- [ ] Agregar métricas de rendimiento
- [ ] Crear tests automatizados
