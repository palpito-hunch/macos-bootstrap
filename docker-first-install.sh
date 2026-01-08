#!/bin/bash

# setup-dev-environment-docker.sh
# Sets up a fresh MacBook Pro for the prediction-market-backend project (Docker-first approach)

set -e  # Exit on error

echo "🚀 Setting up development environment for prediction-market-backend (Docker-first)..."

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "✅ Homebrew already installed"
fi

# Install Node.js 24+
echo "📦 Installing Node.js v24..."
brew install node@24
brew link --overwrite node@24

# Verify Node version
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 24 ]; then
    echo "❌ Node.js version 24 or higher is required"
    exit 1
fi
echo "✅ Node.js $(node -v) installed"

# Verify Git is installed (comes with Xcode Command Line Tools)
if ! command -v git &> /dev/null; then
    echo "📦 Installing Git (via Xcode Command Line Tools)..."
    xcode-select --install
    echo "⚠️  Please complete the Xcode installation and re-run this script"
    exit 1
else
    echo "✅ Git already installed"
fi

# Check for Docker Desktop
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found."
    echo ""
    echo "Please install Docker Desktop manually:"
    echo "  1. Download from: https://www.docker.com/products/docker-desktop"
    echo "  2. Install Docker Desktop"
    echo "  3. Start Docker Desktop"
    echo "  4. Re-run this script"
    exit 1
fi

# Verify Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Docker is installed but not running."
    echo "   Please start Docker Desktop and re-run this script"
    exit 1
fi

echo "✅ Docker is installed and running"

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose not found"
    echo "   Docker Compose should come with Docker Desktop"
    exit 1
fi
echo "✅ Docker Compose available"

echo ""
echo "✨ System dependencies installed successfully!"
echo ""
echo "Next steps:"
echo "  1. Clone the repository: git clone <repository-url>"
echo "  2. Navigate to project: cd prediction-market-backend"
echo "  3. Copy environment file: cp .env.example .env"
echo "  4. Configure .env with Docker connection strings:"
echo "     DATABASE_URL=postgresql://user:password@localhost:5432/dbname"
echo "     REDIS_URL=redis://localhost:6379"
echo "  5. Start Docker services: npm run docker:up"
echo "  6. Install dependencies: npm install"
echo "  7. Generate Prisma client: npm run db:generate"
echo "  8. Run migrations: npm run db:push"
echo "  9. (Optional) Seed database: npm run db:seed"
echo " 10. Start development: npm run dev"
echo ""
echo "💡 Tips:"
echo "  - Stop services: npm run docker:down"
echo "  - View logs: docker-compose logs -f"
echo "  - Reset volumes: docker-compose down -v"
echo ""