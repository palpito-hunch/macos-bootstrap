#!/bin/bash
#
# Development Services Control Script
# Source this file in your .zshrc or .bashrc:
#   source ~/.dev-services.sh
#

# PostgreSQL controls
pg_start() {
    echo "Starting PostgreSQL..."
    brew services start postgresql@16
}

pg_stop() {
    echo "Stopping PostgreSQL..."
    brew services stop postgresql@16
}

pg_restart() {
    echo "Restarting PostgreSQL..."
    brew services restart postgresql@16
}

pg_status() {
    brew services info postgresql@16
}

# Redis controls
redis_start() {
    echo "Starting Redis..."
    brew services start redis
}

redis_stop() {
    echo "Stopping Redis..."
    brew services stop redis
}

redis_restart() {
    echo "Restarting Redis..."
    brew services restart redis
}

redis_status() {
    redis-cli ping 2>/dev/null && echo "Redis is running" || echo "Redis is not running"
}

# Docker controls
docker_start() {
    echo "Starting Docker Desktop..."
    open -a Docker
}

docker_stop() {
    echo "Stopping Docker Desktop..."
    osascript -e 'quit app "Docker"'
}

# All local services
services_start() {
    echo "Starting all local services..."
    pg_start
    redis_start
}

services_stop() {
    echo "Stopping all local services..."
    pg_stop
    redis_stop
}

services_restart() {
    echo "Restarting all local services..."
    pg_restart
    redis_restart
}

services_status() {
    echo "=== PostgreSQL ==="
    pg_status
    echo ""
    echo "=== Redis ==="
    redis_status
}

# Help
services_help() {
    echo "Development Services Commands:"
    echo ""
    echo "  PostgreSQL:"
    echo "    pg_start     - Start PostgreSQL"
    echo "    pg_stop      - Stop PostgreSQL"
    echo "    pg_restart   - Restart PostgreSQL"
    echo "    pg_status    - Check PostgreSQL status"
    echo ""
    echo "  Redis:"
    echo "    redis_start   - Start Redis"
    echo "    redis_stop    - Stop Redis"
    echo "    redis_restart - Restart Redis"
    echo "    redis_status  - Check Redis status"
    echo ""
    echo "  Docker:"
    echo "    docker_start  - Start Docker Desktop"
    echo "    docker_stop   - Stop Docker Desktop"
    echo ""
    echo "  All Local Services:"
    echo "    services_start   - Start PostgreSQL and Redis"
    echo "    services_stop    - Stop PostgreSQL and Redis"
    echo "    services_restart - Restart PostgreSQL and Redis"
    echo "    services_status  - Check all services status"
    echo ""
    echo "    services_help    - Show this help"
}
