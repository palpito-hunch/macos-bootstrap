# Development Environment Setup

This guide will help you set up your development environment for the prediction-market-backend project on macOS.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Setup Options](#setup-options)
- [Docker-First Setup (Recommended)](#docker-first-setup-recommended)
- [Local Install Setup](#local-install-setup)
- [Post-Setup Steps](#post-setup-steps)
- [Common Commands](#common-commands)
- [Troubleshooting](#troubleshooting)

## Prerequisites

All developers will need:
- macOS (tested on versions 10.15+)
- **Node.js 24.0.0 or higher** (required)
- Git (comes with Xcode Command Line Tools)
- Terminal/command line access

## Setup Options

We provide two setup approaches. Choose based on your hardware:

### Docker-First (Recommended for most developers)

**Best for:**
- Apple Silicon Macs (M1/M2/M3) with 16GB+ RAM
- Intel Macs with 32GB+ RAM
- Developers who want consistent, isolated environments
- Teams that need easy database resets

**Resource Usage:** ~1.6-2.7 GB RAM overhead

### Local Install (Performance-Focused)

**Best for:**
- Intel Macs (2019-2020) with 8-16GB RAM
- Developers prioritizing performance
- Systems with limited resources

**Resource Usage:** ~35-65 MB RAM overhead

---

## Docker-First Setup (Recommended)

### Step 1: Download and Run Setup Script

```bash
# Download the setup script
curl -O https://raw.githubusercontent.com/your-org/prediction-market-backend/main/scripts/setup-dev-environment-docker.sh

# Make it executable
chmod +x setup-dev-environment-docker.sh

# Run the script
./setup-dev-environment-docker.sh
```

### Step 2: Install Docker Desktop

If not already installed, download and install Docker Desktop:
1. Visit [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop)
2. Download and install
3. Start Docker Desktop
4. Wait for it to fully start (whale icon in menu bar)

### Step 3: Clone and Configure

```bash
# Clone the repository
git clone <repository-url>
cd prediction-market-backend

# Copy environment template
cp .env.example .env
```

### Step 4: Configure Environment Variables

Edit `.env` with the following Docker connection strings:

```env
# Database
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/prediction_market

# Redis
REDIS_URL=redis://localhost:6379

# Server
PORT=3000
NODE_ENV=development
```

### Step 5: Start Services and Install Dependencies

```bash
# Start PostgreSQL and Redis containers
npm run docker:up

# Install Node.js dependencies
npm install

# Generate Prisma client
npm run db:generate

# Run database migrations
npm run db:push

# (Optional) Seed the database with test data
npm run db:seed
```

### Step 6: Start Development

```bash
# Start the development server
npm run dev
```

You should see output indicating the server is running on `http://localhost:3000`

---

## Local Install Setup

### Step 1: Download and Run Setup Script

```bash
# Download the setup script
curl -O https://raw.githubusercontent.com/your-org/prediction-market-backend/main/scripts/setup-dev-environment-local.sh

# Make it executable
chmod +x setup-dev-environment-local.sh

# Run the script
./setup-dev-environment-local.sh
```

This script installs:
- Node.js 24+
- PostgreSQL 16
- Redis
- Git (if needed)

### Step 2: Clone and Configure

```bash
# Clone the repository
git clone <repository-url>
cd prediction-market-backend

# Copy environment template
cp .env.example .env
```

### Step 3: Create Database

```bash
# Connect to PostgreSQL
psql postgres

# In psql, create the database
CREATE DATABASE prediction_market;
CREATE USER prediction_user WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE prediction_market TO prediction_user;
\q
```

### Step 4: Configure Environment Variables

Edit `.env` with your local connection strings:

```env
# Database (update with your credentials)
DATABASE_URL=postgresql://prediction_user:your_password@localhost:5432/prediction_market

# Redis
REDIS_URL=redis://localhost:6379

# Server
PORT=3000
NODE_ENV=development
```

### Step 5: Install Dependencies and Setup Database

```bash
# Install Node.js dependencies
npm install

# Generate Prisma client
npm run db:generate

# Run database migrations
npm run db:push

# (Optional) Seed the database with test data
npm run db:seed
```

### Step 6: Start Development

```bash
# Start the development server
npm run dev
```

---

## Post-Setup Steps

### Verify Installation

```bash
# Check Node.js version (should be 24+)
node -v

# Check npm version
npm -v

# Run tests
npm test

# Check linting
npm run lint

# Check type safety
npm run type-check
```

### IDE Setup (Recommended)

For the best development experience, install these VS Code extensions:
- ESLint
- Prettier
- Prisma
- TypeScript

---

## Common Commands

### Development

```bash
npm run dev              # Start development server with hot reload
npm run build            # Build for production
npm start                # Start production server
```

### Testing

```bash
npm test                 # Run unit tests
npm run test:watch       # Run tests in watch mode
npm run test:coverage    # Run tests with coverage report
npm run test:integration # Run integration tests
npm run test:all         # Run all tests
```

### Database

```bash
npm run db:generate      # Generate Prisma client
npm run db:push          # Push schema changes to database
npm run db:migrate       # Run migrations
npm run db:seed          # Seed database with test data
```

### Docker (Docker-First Setup Only)

```bash
npm run docker:up        # Start PostgreSQL and Redis containers
npm run docker:down      # Stop and remove containers
docker-compose logs -f   # View container logs
docker-compose down -v   # Stop containers and remove volumes (full reset)
```

### Code Quality

```bash
npm run lint             # Run ESLint
npm run lint:fix         # Auto-fix linting issues
npm run format           # Format code with Prettier
npm run type-check       # Check TypeScript types
npm run quality:check    # Run all quality checks
```

---

## Troubleshooting

### Docker Issues

**Docker Desktop not running:**
```bash
# Check if Docker is running
docker info

# If not, start Docker Desktop from Applications
```

**Port conflicts:**
```bash
# Check what's using port 5432 (PostgreSQL)
lsof -i :5432

# Check what's using port 6379 (Redis)
lsof -i :6379

# Kill the process or change ports in docker-compose.yml
```

**Database connection errors:**
```bash
# Reset Docker volumes
docker-compose down -v
npm run docker:up
npm run db:push
```

### Local Install Issues

**PostgreSQL not starting:**
```bash
# Check PostgreSQL status
brew services list

# Restart PostgreSQL
brew services restart postgresql@16

# Check logs
tail -f /opt/homebrew/var/log/postgresql@16.log
```

**Redis not starting:**
```bash
# Check Redis status
brew services list

# Restart Redis
brew services restart redis

# Test connection
redis-cli ping
# Should return: PONG
```

**Node version issues:**
```bash
# Check current version
node -v

# If wrong version, ensure node@24 is linked
brew link --overwrite node@24

# Restart terminal
```

### Prisma Issues

**Prisma Client out of sync:**
```bash
# Regenerate Prisma client
npm run db:generate

# If that doesn't work, delete and regenerate
rm -rf node_modules/.prisma
npm run db:generate
```

**Migration issues:**
```bash
# Reset database (WARNING: deletes all data)
npx prisma migrate reset

# Or manually drop and recreate
npm run db:push
```

### General Issues

**Port 3000 already in use:**
```bash
# Find process using port 3000
lsof -i :3000

# Kill the process
kill -9 <PID>

# Or change PORT in .env
```

**Permission errors:**
```bash
# Fix npm permissions
sudo chown -R $(whoami) ~/.npm
sudo chown -R $(whoami) /usr/local/lib/node_modules
```

**Husky hooks failing:**
```bash
# Reinstall git hooks
npm run prepare

# If still failing, check .husky directory permissions
chmod +x .husky/*
```

---

## Switching Between Setups

### From Docker to Local

```bash
# Stop Docker containers
npm run docker:down

# Start local services
brew services start postgresql@16
brew services start redis

# Update .env with local connection strings
# DATABASE_URL=postgresql://user:pass@localhost:5432/dbname

# Restart development server
npm run dev
```

### From Local to Docker

```bash
# Stop local services
brew services stop postgresql@16
brew services stop redis

# Update .env with Docker connection strings
# DATABASE_URL=postgresql://postgres:postgres@localhost:5432/prediction_market

# Start Docker containers
npm run docker:up

# Restart development server
npm run dev
```

---

## Additional Resources

- [Node.js Documentation](https://nodejs.org/docs/latest-v24.x/api/)
- [TypeScript Documentation](https://www.typescriptlang.org/docs/)
- [Prisma Documentation](https://www.prisma.io/docs)
- [Express.js Documentation](https://expressjs.com/)
- [Socket.IO Documentation](https://socket.io/docs/)
- [Docker Documentation](https://docs.docker.com/)

---

## Getting Help

If you encounter issues not covered in this guide:
1. Check existing GitHub issues
2. Search the project documentation
3. Ask in the team Slack channel
4. Create a new GitHub issue with:
   - Your macOS version
   - Your hardware (Intel vs Apple Silicon)
   - Setup approach used (Docker vs Local)
   - Error messages and logs
   - Steps to reproduce

---

## Contributing

Before submitting a pull request:
1. Run `npm run quality:check` to verify code quality
2. Run `npm run test:all` to ensure all tests pass
3. Ensure your `.env` changes are reflected in `.env.example`
4. Update documentation if you've changed setup procedures