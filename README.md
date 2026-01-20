# Development Environment Setup

Bootstrap a new macOS machine with development tools and AI coding assistants.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/palpito-hunch/development-environment-setup/main/macos-setup.sh | bash
```

## Script Options

| Flag | Short | Description |
|------|-------|-------------|
| (none) | | Full install: software + shell commands |
| `--software` | `-s` | Install/update software only |
| `--aliases` | `-a` | Update shell commands only |
| `--all` | | Same as no flags |
| `--help` | `-h` | Show usage |

```bash
# Full install (new machine)
curl -fsSL .../macos-setup.sh | bash

# Update shell commands only (when dev-services.sh changes)
curl -fsSL .../macos-setup.sh | bash -s -- --aliases

# Install software only (skip shell config)
curl -fsSL .../macos-setup.sh | bash -s -- --software
```

## What Gets Installed

### Software (--software)

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

### Shell Commands (--aliases)

Installs `~/.dev-services.sh` and sources it in your shell config.

## Shell Commands Reference

### Project Creation

```bash
new_backend my-api      # Create backend from template
new_frontend my-app     # Create frontend from template
```

Creates private repos in `palpito-hunch` org using GitHub's template feature.

### Service Controls

```bash
# PostgreSQL
pg_start              pg_stop              pg_restart           pg_status

# Redis
redis_start           redis_stop           redis_restart        redis_status

# Docker
docker_start          docker_stop

# All Local Services
services_start        services_stop        services_restart     services_status

# Help
services_help
```

## Troubleshooting

### Docker

```bash
docker info           # Check if running
docker_start          # Start Docker Desktop
```

### PostgreSQL

```bash
pg_status             # Check status
pg_restart            # Restart service
tail -f /opt/homebrew/var/log/postgresql@16.log  # View logs
```

### Redis

```bash
redis_status          # Check status
redis_restart         # Restart service
redis-cli ping        # Test connection
```

### Port Conflicts

```bash
lsof -i :5432         # What's using PostgreSQL port
lsof -i :6379         # What's using Redis port
kill -9 <PID>         # Kill process
```

## Updating

```bash
# Update shell commands when new features are added
curl -fsSL .../macos-setup.sh | bash -s -- --aliases

# Full re-run (idempotent, safe to repeat)
curl -fsSL .../macos-setup.sh | bash
```
