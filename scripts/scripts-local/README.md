# Documentación de Scripts para Entorno Local

Esta documentación describe los scripts de administración y desarrollo para la aplicación Laravel API en entorno **LOCAL** con Docker.

---

## Índice

1. [backup-db.sh](#backup-dbsh) - Backup y restauración de MySQL local
2. [deploy.sh](#deploysh) - Commit y push a GitHub
3. [estado-contenedores.sh](#estado-contenedoressh) - Monitoreo de contenedores Docker locales
4. [limpiar-cache.sh](#limpiar-cachesh) - Limpieza de cache de Laravel
5. [reiniciar-app.sh](#reiniciar-appsh) - Reinicio completo de la aplicación local
6. [ver-logs.sh](#ver-logssh) - Visor de logs interactivo

---

## Diferencias con Scripts VPS

| Característica | Local | VPS |
|----------------|-------|-----|
| Comandos Docker | Sin `sudo` | Con `sudo` |
| Nombres contenedores | `laravel-*` | `api-laravel-1-*` |
| Credenciales DB | `password` | Password producción |
| URL | `http://localhost:8000` | `https://api.smartdigitaltec.com` |
| Deploy | `git push` | `git pull` |
| Backups | `~/backups/mysql-local` | `~/backups/mysql` |

---

## backup-db.sh

**Ubicación:** `scripts/scripts-local/backup-db.sh`

### Descripción
Script interactivo para backup y restauración de la base de datos MySQL en entorno local. Ideal para crear snapshots antes de migraciones o cambios importantes en desarrollo.

### Características principales
- **Backup manual**: Crea backup comprimido (.sql.gz) con timestamp
- **Listado de backups**: Muestra todos los backups disponibles con tamaño y fecha
- **Restauración**: Permite restaurar la BD desde cualquier backup
- **Limpieza automática**: Elimina backups antiguos por días
- **Backup automático (cron)**: Configura backups programados
- **Monitoreo**: Muestra espacio en disco y logs de backup

### Configuración
```bash
CONTAINER_MYSQL="laravel-mysql-1"
DB_NAME="laravel"
DB_USER="laravel"
DB_PASSWORD="password"
BACKUP_DIR="$HOME/backups/mysql-local"
```

### Uso
```bash
cd /home/jeans/proyectos/laravel-docker-test/laravel/scripts/scripts-local
bash backup-db.sh
```

### Menú de opciones
1. **Crear backup ahora** - Genera backup manual inmediato
2. **Ver backups existentes** - Lista todos los backups con información
3. **Restaurar desde backup** - Selecciona y restaura un backup (requiere confirmación 'SI')
4. **Eliminar backups antiguos** - Elimina backups con más de X días
5. **Configurar backup automático (cron)** - Configura backups programados:
   - Diario a las 2:00 AM
   - Cada 12 horas
   - Cada 6 horas
   - Semanal (Domingos 3:00 AM)
   - Personalizado
6. **Ver espacio en disco** - Muestra uso de disco y cantidad de backups
7. **Ver log de backups** - Muestra últimas 30 líneas del log

### Casos de uso
```bash
# Antes de una migración peligrosa
bash backup-db.sh
# Opción 1: Crear backup ahora

# Después de un error, restaurar
bash backup-db.sh
# Opción 3: Restaurar desde backup
```

### Archivos generados
- `$HOME/backups/mysql-local/backup_laravel_YYYYMMDD_HHMMSS.sql.gz` - Archivos de backup
- `$HOME/backups/mysql-local/backup.log` - Log de operaciones
- `$HOME/backups/mysql-local/auto-backup.sh` - Script de backup automático (si se configura)
- `$HOME/backups/mysql-local/cron.log` - Log de ejecuciones cron

### Notas
- Los backups se comprimen automáticamente con gzip
- La restauración limpia automáticamente el cache de Laravel
- Los backups automáticos eliminan archivos con más de 30 días
- No requiere `sudo` como en VPS

---

## deploy.sh

**Ubicación:** `scripts/scripts-local/deploy.sh`

### Descripción
Script para hacer commit y push de cambios locales a GitHub. Diseñado para flujo de desarrollo local donde creas código y subes cambios al repositorio.

### Características principales
- Detección automática de cambios pendientes
- Commit interactivo con mensaje personalizado
- Push a GitHub
- Opciones post-deploy: limpiar cache, migraciones, reinicio

### Configuración
```bash
PROJECT_DIR="/home/jeans/proyectos/laravel-docker-test/laravel"
```

### Uso
```bash
cd /home/jeans/proyectos/laravel-docker-test/laravel/scripts/scripts-local
bash deploy.sh
```

### Flujo de ejecución

#### Escenario 1: Con cambios pendientes
1. Muestra branch actual
2. Lista archivos modificados (`git status -s`)
3. Pregunta si deseas agregar y commitear
4. Solicita mensaje de commit
5. Ejecuta `git add .`
6. Ejecuta `git commit -m "mensaje"`
7. Pregunta si hacer push a GitHub
8. Ejecuta `git push origin <branch>`
9. Opciones adicionales (cache, migraciones, reinicio)

#### Escenario 2: Sin cambios pendientes
1. Muestra branch actual
2. Indica que no hay cambios
3. Pregunta si deseas hacer push de commits existentes
4. Ejecuta `git push origin <branch>`
5. Opciones adicionales

### Opciones interactivas
- **Agregar y commitear cambios**: Solo si hay archivos modificados
- **Push a GitHub**: Sube commits al repositorio remoto
- **Limpiar cache**: `config:clear`, `cache:clear`, `view:clear`
- **Ejecutar migraciones**: `php artisan migrate`
- **Reiniciar contenedores**: `docker compose restart app nginx`

### Ejemplo de uso
```bash
# Has modificado varios archivos
bash deploy.sh

# Output:
# 📍 Branch actual: main
# 📋 Cambios pendientes:
#  M app/Http/Controllers/UserController.php
#  M routes/api.php
#
# ¿Deseas agregar y commitear estos cambios? (y/n): y
# Mensaje del commit: agregando endpoint de usuarios
# 📝 Agregando cambios...
# 💾 Creando commit...
# ✅ Commit creado
# ¿Hacer push a GitHub? (y/n): y
# 📤 Haciendo push a GitHub...
# ✅ Push completado
```

### Diferencia con VPS
- **Local (push)**: `git add` → `git commit` → `git push`
- **VPS (pull)**: `git pull` → aplicar cambios

---

## estado-contenedores.sh

**Ubicación:** `scripts/scripts-local/estado-contenedores.sh`

### Descripción
Dashboard interactivo completo para monitorear el estado de todos los contenedores Docker locales. Proporciona información detallada sobre salud, recursos, redes y volúmenes.

### Contenedores monitoreados
- `laravel-app-1` - Aplicación Laravel (PHP-FPM)
- `laravel-nginx-1` - Servidor web Nginx
- `laravel-mysql-1` - Base de datos MySQL
- `laravel-redis-1` - Cache Redis

### Configuración
```bash
PROJECT_DIR="/home/jeans/proyectos/laravel-docker-test/laravel"
CONTAINER_APP="laravel-app-1"
CONTAINER_NGINX="laravel-nginx-1"
CONTAINER_MYSQL="laravel-mysql-1"
CONTAINER_REDIS="laravel-redis-1"
```

### Uso
```bash
cd /home/jeans/proyectos/laravel-docker-test/laravel/scripts/scripts-local
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
5. **Ver redes Docker** - Lista todas las redes y detalles de la red 'laravel_default'
6. **Ver volúmenes** - Muestra volúmenes y espacio usado por MySQL
7. **Ver imágenes** - Lista imágenes Docker y espacio total usado

#### Opciones de gestión
8. **Reiniciar contenedor** - Reinicia un contenedor específico
9. **Reiniciar todos** - Reinicia todos los contenedores (requiere confirmación)
10. **Monitoreo en tiempo real** - Vista de procesos con `docker compose top`

### Información mostrada

#### Dashboard completo
```
╔════════════════════════════════════════════════════════════════════╗
║              📊 DASHBOARD DE CONTENEDORES - LOCAL                 ║
╚════════════════════════════════════════════════════════════════════╝

🕐 Fecha: 2025-10-14 01:30:00
🌐 Host: tu-hostname

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📱 Laravel Application
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Contenedor:  laravel-app-1
   Estado:      ● Running
   Uptime:      2 hours
   Health:      ✓ Healthy
   IP:          172.18.0.2
   Puerto:      9000

[...similar para nginx, mysql, redis...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📈 Resumen
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Contenedores corriendo: 4/4
   Red:                     laravel_default
   URL Local:               http://localhost:8000
```

### Casos de uso
```bash
# Verificar que todos los contenedores están corriendo
bash estado-contenedores.sh
# Opción 1: Dashboard completo

# Monitorear uso de CPU/RAM mientras desarrollas
bash estado-contenedores.sh
# Opción 3: Uso de recursos

# Ver detalles de un contenedor específico
bash estado-contenedores.sh
# Opción 4: Detalles de contenedor específico
```

### Notas
- No requiere `sudo` como en VPS
- Red por defecto: `laravel_default`
- Todos los comandos usan `docker` (sin sudo)

---

## limpiar-cache.sh

**Ubicación:** `scripts/scripts-local/limpiar-cache.sh`

### Descripción
Script simple para limpiar todos los tipos de cache de Laravel en entorno local. Ejecuta comandos artisan de limpieza en el contenedor Docker.

### Características
- Limpieza de configuración
- Limpieza de cache de aplicación
- Limpieza de cache de rutas
- Limpieza de vistas compiladas
- Limpieza de eventos cacheados
- Optimización del autoloader de Composer

### Configuración
```bash
CONTAINER_NAME="laravel-app-1"
```

### Uso
```bash
cd /home/jeans/proyectos/laravel-docker-test/laravel/scripts/scripts-local
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

### Salida ejemplo
```
================================================
   Limpiando cache de Laravel - LOCAL
================================================

→ Ejecutando: php artisan config:clear
Configuration cache cleared successfully.
✓ Completado

→ Ejecutando: php artisan cache:clear
Application cache cleared successfully.
✓ Completado

[...continúa con todos los comandos...]

================================================
✓ Cache limpiado exitosamente
================================================
```

### Cuándo usar
- Después de cambiar archivos `.env`
- Después de modificar archivos de configuración en `config/`
- Cuando las rutas no se actualizan
- Después de cambiar vistas
- Al experimentar comportamiento inesperado
- Antes de ejecutar tests importantes

### Casos de uso
```bash
# Cambios en .env no se reflejan
bash limpiar-cache.sh

# Después de modificar config/app.php
bash limpiar-cache.sh

# Debug de problemas raros
bash limpiar-cache.sh
```

---

## reiniciar-app.sh

**Ubicación:** `scripts/scripts-local/reiniciar-app.sh`

### Descripción
Script completo para reiniciar toda la aplicación Laravel en entorno local. Reinicia contenedores Docker, espera a que estén listos, verifica conexiones y limpia cache.

### Características principales
- Reinicio ordenado de todos los contenedores
- Espera inteligente para que servicios inicien
- Verificación de estado de MySQL
- Limpieza automática de cache
- Verificación de conexión a base de datos
- Información útil al finalizar

### Configuración
```bash
PROJECT_DIR="/home/jeans/proyectos/laravel-docker-test/laravel"
CONTAINER_APP="laravel-app-1"
CONTAINER_NGINX="laravel-nginx-1"
CONTAINER_MYSQL="laravel-mysql-1"
CONTAINER_REDIS="laravel-redis-1"
```

### Uso
```bash
cd /home/jeans/proyectos/laravel-docker-test/laravel/scripts/scripts-local
bash reiniciar-app.sh
```

### Proceso de reinicio (9 pasos)

1. **Navegación**: Navega al directorio del proyecto
2. **Verificación inicial**: Muestra estado actual con `docker compose ps`
3. **Reinicio**: Reinicia todos los contenedores con `docker compose restart`
4. **Espera**: Countdown de 10 segundos para inicio de servicios
5. **Verificación MySQL**: Intenta conectar a MySQL (hasta 10 intentos)
6. **Limpieza de cache**: Ejecuta comandos artisan de limpieza
7. **Estado final**: Muestra estado de contenedores
8. **Test de conexión BD**: Verifica conexión con tinker
9. **Información útil**: Muestra URL, contenedores activos y comandos útiles

### Salida ejemplo
```
╔════════════════════════════════════════════╗
║   🔄 REINICIANDO APLICACIÓN LARAVEL       ║
║              (LOCAL)                       ║
╚════════════════════════════════════════════╝

┌─ Navegando al directorio del proyecto...
└─ ✓ Directorio: /home/jeans/proyectos/laravel-docker-test/laravel

┌─ Verificando estado actual de contenedores...
NAME                 IMAGE               STATUS
laravel-app-1        php:8.2-fpm         Up 2 hours
laravel-nginx-1      nginx:alpine        Up 2 hours
laravel-mysql-1      mysql:8.0           Up 2 hours
laravel-redis-1      redis:alpine        Up 2 hours

┌─ Reiniciando contenedores Docker...
└─ ✓ Contenedores reiniciados

┌─ Esperando a que los servicios inicien (10 segundos)...
   ⏳ 10 segundos restantes...
└─ ✓ Servicios iniciados

┌─ Verificando conexión a MySQL...
└─ ✓ MySQL está listo

┌─ Limpiando cache de Laravel...
└─ ✓ Cache limpiado

┌─ Estado final de los contenedores:
[...muestra docker compose ps...]

┌─ Verificando conexión a la base de datos...
└─ ✓ Conexión a base de datos: OK

╔════════════════════════════════════════════╗
║   ✅ APLICACIÓN REINICIADA EXITOSAMENTE   ║
╚════════════════════════════════════════════╝

📊 Información útil:
   🌐 URL Local: http://localhost:8000
   📦 Contenedores activos: 4/4

🔧 Comandos útiles:
   • Ver logs:        docker logs -f laravel-app-1
   • Estado MySQL:    docker exec laravel-mysql-1 mysqladmin ping
   • Artisan tinker:  docker exec -it laravel-app-1 php artisan tinker
```

### Verificaciones
- **MySQL ping**: Verifica que MySQL esté respondiendo
- **Test de conexión BD**: Usa Laravel Tinker para verificar conexión PDO

### Cuándo usar
- Después de cambios en configuración Docker
- Cuando un contenedor no responde
- Después de modificar archivos `.env`
- Para resolver problemas de conexión
- Al inicio de sesión de desarrollo
- Después de actualizar imágenes Docker

### Casos de uso
```bash
# Contenedor MySQL no responde
bash reiniciar-app.sh

# Después de cambiar .env
bash reiniciar-app.sh

# Inicio del día de desarrollo
bash reiniciar-app.sh
```

---

## ver-logs.sh

**Ubicación:** `scripts/scripts-local/ver-logs.sh`

### Descripción
Visor interactivo de logs para todos los contenedores Docker y logs de Laravel en entorno local. Permite ver logs en tiempo real, buscar errores y filtrar información.

### Configuración
```bash
CONTAINER_APP="laravel-app-1"
CONTAINER_NGINX="laravel-nginx-1"
CONTAINER_MYSQL="laravel-mysql-1"
CONTAINER_REDIS="laravel-redis-1"
```

### Uso
```bash
cd /home/jeans/proyectos/laravel-docker-test/laravel/scripts/scripts-local
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
- **Tiempo real**: Usa `tail -f` para seguimiento continuo (Ctrl+C para salir)
- **Filtrado**: Opción para ver solo errores
- **Búsqueda**: Búsqueda case-insensitive con grep
- **Últimas N líneas**: Muestra cantidad configurable de líneas (default: 50-100)

### Comandos ejecutados

#### Logs de Docker
```bash
# Log específico
docker logs -f --tail 100 <container>

# Todos los logs
docker compose logs -f --tail 50
```

#### Logs de Laravel
```bash
# Tiempo real
docker exec -it laravel-app-1 tail -f /var/www/storage/logs/laravel.log

# Solo errores
docker exec -it laravel-app-1 tail -f /var/www/storage/logs/laravel.log | grep -i "error|exception|fatal"

# Últimas líneas
docker exec -it laravel-app-1 tail -50 /var/www/storage/logs/laravel.log

# Búsqueda
docker exec -it laravel-app-1 grep -i "término" /var/www/storage/logs/laravel.log | tail -50
```

### Casos de uso

#### Desarrollo activo
```bash
# Terminal 1: Ver logs en tiempo real mientras desarrollas
bash ver-logs.sh
# Opción 6: Laravel logs

# Terminal 2: Hacer requests a la API
curl http://localhost:8000/api/users
```

#### Debug de errores
```bash
# Ver solo errores
bash ver-logs.sh
# Opción 7: Logs de errores de Laravel
```

#### Análisis post-error
```bash
# Buscar un término específico
bash ver-logs.sh
# Opción 9: Buscar en logs
# Ingresa: UserController
```

#### Problemas de conexión
```bash
# Ver logs de MySQL
bash ver-logs.sh
# Opción 3: MySQL
```

#### Problemas de Nginx
```bash
# Ver logs de Nginx
bash ver-logs.sh
# Opción 2: Nginx
```

### Ejemplos de salida

#### Laravel logs en tiempo real
```
[2025-10-14 01:45:23] local.INFO: User logged in {"user_id":1}
[2025-10-14 01:45:24] local.INFO: API request {"endpoint":"/api/users"}
[2025-10-14 01:45:25] local.ERROR: Database connection failed
[2025-10-14 01:45:26] local.INFO: Retrying connection...
```

#### Logs de errores filtrados
```
[2025-10-14 01:45:25] local.ERROR: Database connection failed
[2025-10-14 01:50:12] local.ERROR: Undefined variable $user in UserController.php:45
[2025-10-14 01:52:30] local.EXCEPTION: SQLSTATE[HY000] [2002] Connection refused
```

### Tips
- Mantén abierto en una terminal mientras desarrollas
- Usa búsqueda para encontrar errores específicos rápidamente
- Combina con `reiniciar-app.sh` para debug completo
- Los logs de Laravel se guardan en `storage/logs/laravel.log`

---

## Requisitos generales

### Sistema operativo
- Linux (probado en Ubuntu/Debian/WSL2)
- Bash shell

### Software requerido
- Docker y Docker Compose (sin necesidad de sudo)
- Git
- Usuario con permisos Docker (grupo docker)

### Estructura de directorios
```
/home/jeans/proyectos/laravel-docker-test/
└── laravel/
    ├── docker-compose.yml
    ├── scripts/
    │   └── scripts-local/          # Scripts locales
    │       ├── backup-db.sh
    │       ├── deploy.sh
    │       ├── estado-contenedores.sh
    │       ├── limpiar-cache.sh
    │       ├── reiniciar-app.sh
    │       └── ver-logs.sh
    └── ...

$HOME/
└── backups/
    └── mysql-local/                # Backups (auto-creado)
```

---

## Flujo de trabajo típico en desarrollo local

### Inicio del día
```bash
# 1. Iniciar contenedores
cd /home/jeans/proyectos/laravel-docker-test/laravel
docker compose up -d

# 2. Ver estado
bash scripts/scripts-local/estado-contenedores.sh
# Opción 1: Dashboard completo

# 3. Ver logs en tiempo real (terminal separada)
bash scripts/scripts-local/ver-logs.sh
# Opción 6: Laravel logs
```

### Durante el desarrollo
```bash
# Limpiar cache después de cambios en config
bash scripts/scripts-local/limpiar-cache.sh

# Ver logs de errores
bash scripts/scripts-local/ver-logs.sh
# Opción 7: Logs de errores

# Reiniciar si algo falla
bash scripts/scripts-local/reiniciar-app.sh
```

### Antes de una migración
```bash
# Crear backup de seguridad
bash scripts/scripts-local/backup-db.sh
# Opción 1: Crear backup ahora

# Ejecutar migración
docker exec laravel-app-1 php artisan migrate

# Si algo sale mal, restaurar
bash scripts/scripts-local/backup-db.sh
# Opción 3: Restaurar desde backup
```

### Al finalizar el día
```bash
# Commitear y pushear cambios
bash scripts/scripts-local/deploy.sh
# Seguir las instrucciones interactivas

# Apagar contenedores (opcional)
cd /home/jeans/proyectos/laravel-docker-test/laravel
docker compose down
```

---

## Mejores prácticas para desarrollo local

### Backups
- Crear backup antes de migraciones importantes
- Crear backup antes de seeds masivos
- No es necesario backup automático diario en local (a menos que trabajes con datos importantes)
- Mantener backups de estados "limpios" de la BD

### Git y Deploy
- Commitear frecuentemente con mensajes descriptivos
- Hacer push al menos una vez al día
- No commitear archivos `.env` o credenciales
- Revisar `git status` antes de commitear

### Cache
- Limpiar cache después de cambios en `.env`
- Limpiar cache después de modificar archivos en `config/`
- No limpiar cache innecesariamente (ralentiza la app)

### Logs
- Mantener terminal con logs en tiempo real durante desarrollo
- Buscar errores específicos con la opción de búsqueda
- Limpiar logs antiguos periódicamente: `echo "" > storage/logs/laravel.log`

### Contenedores
- Reiniciar solo cuando sea necesario
- Verificar estado con dashboard antes de reiniciar
- No hacer `docker compose down` a menos que necesites limpiar volúmenes

---

## Solución de problemas comunes

### Contenedor no inicia
```bash
# Ver qué contenedor falla
bash scripts/scripts-local/estado-contenedores.sh
# Opción 2: Estado resumido

# Ver logs del contenedor
bash scripts/scripts-local/ver-logs.sh
# Opción correspondiente

# Reiniciar
bash scripts/scripts-local/reiniciar-app.sh
```

### Error de conexión a base de datos
```bash
# Verificar que MySQL está corriendo
docker ps | grep mysql

# Ver logs de MySQL
bash scripts/scripts-local/ver-logs.sh
# Opción 3: MySQL

# Verificar conexión
docker exec laravel-mysql-1 mysqladmin ping -h localhost -u laravel -ppassword

# Reiniciar con verificación
bash scripts/scripts-local/reiniciar-app.sh
```

### Cambios en .env no se reflejan
```bash
# Limpiar cache
bash scripts/scripts-local/limpiar-cache.sh

# Reiniciar contenedor app
docker restart laravel-app-1
```

### Error "Port 8000 already in use"
```bash
# Ver qué proceso usa el puerto
sudo lsof -i :8000

# O usar otro puerto en docker-compose.yml
# ports:
#   - "8001:80"  # Cambiar de 8000 a 8001
```

### Git push rechazado
```bash
# Puede que el remoto tenga commits que no tienes
cd /home/jeans/proyectos/laravel-docker-test/laravel
git pull origin main --rebase

# Resolver conflictos si los hay
# Luego hacer push
git push origin main
```

### Error al restaurar backup
```bash
# Verificar que el archivo existe
ls -lh ~/backups/mysql-local/

# Verificar que MySQL está corriendo
docker ps | grep mysql

# Intentar restauración manual
gunzip -c ~/backups/mysql-local/backup_laravel_*.sql.gz | docker exec -i laravel-mysql-1 mysql -u laravel -ppassword laravel
```

---

## Comandos útiles adicionales

### Docker
```bash
# Ver todos los contenedores
docker ps -a

# Ver logs de un contenedor específico
docker logs -f laravel-app-1

# Entrar a un contenedor
docker exec -it laravel-app-1 bash

# Ver uso de recursos en tiempo real
docker stats

# Limpiar todo Docker (cuidado!)
docker system prune -a
```

### Laravel Artisan
```bash
# Ejecutar comando artisan
docker exec laravel-app-1 php artisan <comando>

# Tinker (REPL de Laravel)
docker exec -it laravel-app-1 php artisan tinker

# Crear migración
docker exec laravel-app-1 php artisan make:migration create_users_table

# Crear controlador
docker exec laravel-app-1 php artisan make:controller UserController
```

### Base de datos
```bash
# Acceder a MySQL CLI
docker exec -it laravel-mysql-1 mysql -u laravel -ppassword laravel

# Exportar BD manualmente
docker exec laravel-mysql-1 mysqldump -u laravel -ppassword laravel > backup.sql

# Importar BD manualmente
docker exec -i laravel-mysql-1 mysql -u laravel -ppassword laravel < backup.sql
```

### Git
```bash
# Ver estado
git status

# Ver diferencias
git diff

# Ver historial
git log --oneline

# Deshacer último commit (mantiene cambios)
git reset --soft HEAD~1

# Ver branches
git branch -a
```

---

## Diferencias detalladas: Local vs VPS

### Comandos Docker
```bash
# Local
docker compose ps
docker exec laravel-app-1 php artisan migrate

# VPS
sudo docker compose ps
sudo docker exec api-laravel-1-app php artisan migrate
```

### URLs
```bash
# Local
http://localhost:8000
http://localhost:8080  # phpMyAdmin (si está configurado)

# VPS
https://api.smartdigitaltec.com
```

### Base de datos
```bash
# Local
Host: localhost
Port: 3306
Database: laravel
User: laravel
Password: password

# VPS
Host: VPS IP
Port: 3306
Database: laravel
User: laravel
Password: PeruadmLima25$
```

### Flujo Git
```bash
# Local
git add .
git commit -m "mensaje"
git push origin main

# VPS
git pull origin main
```

---

## Scripts auxiliares (opcional)

### Crear script de inicio rápido
```bash
# Crear ~/dev-start.sh
cat > ~/dev-start.sh << 'EOF'
#!/bin/bash
cd /home/jeans/proyectos/laravel-docker-test/laravel
docker compose up -d
bash scripts/scripts-local/estado-contenedores.sh
EOF

chmod +x ~/dev-start.sh
```

### Crear alias útiles
```bash
# Agregar a ~/.bashrc o ~/.zshrc
alias laravel-cd='cd /home/jeans/proyectos/laravel-docker-test/laravel'
alias laravel-up='cd /home/jeans/proyectos/laravel-docker-test/laravel && docker compose up -d'
alias laravel-down='cd /home/jeans/proyectos/laravel-docker-test/laravel && docker compose down'
alias laravel-logs='cd /home/jeans/proyectos/laravel-docker-test/laravel && bash scripts/scripts-local/ver-logs.sh'
alias laravel-cache='cd /home/jeans/proyectos/laravel-docker-test/laravel && bash scripts/scripts-local/limpiar-cache.sh'
alias laravel-restart='cd /home/jeans/proyectos/laravel-docker-test/laravel && bash scripts/scripts-local/reiniciar-app.sh'
alias laravel-deploy='cd /home/jeans/proyectos/laravel-docker-test/laravel && bash scripts/scripts-local/deploy.sh'
alias laravel-backup='cd /home/jeans/proyectos/laravel-docker-test/laravel && bash scripts/scripts-local/backup-db.sh'
alias laravel-status='cd /home/jeans/proyectos/laravel-docker-test/laravel && bash scripts/scripts-local/estado-contenedores.sh'
```

Usar:
```bash
source ~/.bashrc  # o source ~/.zshrc

# Ahora puedes usar:
laravel-up
laravel-logs
laravel-deploy
```

---

## Contacto y soporte

Para reportar problemas o sugerencias sobre estos scripts, contactar al equipo de desarrollo.

**Entorno**: Local Development
**URL de la aplicación**: http://localhost:8000

---

## Changelog

### Versión actual (Local)
- Scripts completos y funcionales para desarrollo local:
  - Backup/restauración de BD local
  - Deploy con commit y push a GitHub
  - Monitoreo de contenedores locales
  - Gestión de cache
  - Reinicio de aplicación local
  - Visualización de logs

### Diferencias con scripts VPS
- Sin comandos `sudo`
- Nombres de contenedores con prefijo `laravel-`
- Credenciales de desarrollo
- Git push en lugar de pull
- Directorio de backups separado

### Mejoras futuras sugeridas
- [ ] Agregar script para seed de datos de prueba
- [ ] Agregar script para ejecutar tests
- [ ] Agregar script para crear nueva migración
- [ ] Integración con herramientas de desarrollo (xdebug, etc.)
- [ ] Agregar validación de código (phpcs, phpstan)
