# Development Environment Setup

Bootstrap a new macOS machine with development tools and AI coding assistants.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/palpito-hunch/development-environment-setup/main/macos-setup.sh | bash
```

## What It Does

The script prompts you to choose a setup type:

| Option | Installs | Best For |
|--------|----------|----------|
| **[1] Docker** | Docker Desktop | Apple Silicon 16GB+, Intel 32GB+ |
| **[2] Local** | PostgreSQL 16, Redis | Intel Macs 8-16GB |
| **[3] Both** | All of the above | Maximum flexibility |

All options install:

| Category | Tools |
|----------|-------|
| **CLI Tools** | git, gh (GitHub CLI), node, npm |
| **Applications** | Sublime Text, Slack, MacDown, Kiro |
| **AI Assistants** | Claude Code |
| **Org Setup** | ai-rules, backend-template, frontend-template |

## Shell Commands

The script installs shell functions to `~/.dev-services.sh`:

### Project Creation

```bash
# Create a new backend project from template
new_backend my-api

# Create a new frontend project from template
new_frontend my-app
```

Projects are created as private repos in the `palpito-hunch` org using GitHub's template feature.

### Service Controls

```bash
# PostgreSQL
pg_start          # Start PostgreSQL
pg_stop           # Stop PostgreSQL
pg_restart        # Restart PostgreSQL
pg_status         # Check status

# Redis
redis_start       # Start Redis
redis_stop        # Stop Redis
redis_restart     # Restart Redis
redis_status      # Check status

# Docker
docker_start      # Start Docker Desktop
docker_stop       # Stop Docker Desktop

# All Local Services
services_start    # Start PostgreSQL and Redis
services_stop     # Stop PostgreSQL and Redis
services_restart  # Restart all
services_status   # Check all status

services_help     # Show all commands
```

## Troubleshooting

### Docker

```bash
# Check if Docker is running
docker info

# Start Docker Desktop
docker_start
# or: open -a Docker
```

### PostgreSQL

```bash
# Check status
pg_status

# Restart
pg_restart

# View logs
tail -f /opt/homebrew/var/log/postgresql@16.log
```

### Redis

```bash
# Check status
redis_status

# Restart
redis_restart

# Test connection
redis-cli ping
```

### Port Conflicts

```bash
# Check what's using a port
lsof -i :5432    # PostgreSQL
lsof -i :6379    # Redis

# Kill process
kill -9 <PID>
```

## Re-running the Script

The script is idempotent and can be safely re-run to:
- Install missing tools
- Update to a different setup type
- Fix broken installations
