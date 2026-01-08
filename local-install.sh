#!/bin/bash

# setup-dev-environment.sh
# Sets up a fresh MacBook Pro for the prediction-market-backend project

set -e  # Exit on error

echo "🚀 Setting up development environment for prediction-market-backend..."

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

# Install PostgreSQL
echo "📦 Installing PostgreSQL..."
brew install postgresql@16
brew services start postgresql@16
echo "✅ PostgreSQL installed and started"

# Install Redis
echo "📦 Installing Redis..."
brew install redis
brew services start redis
echo "✅ Redis installed and started"

# Install Docker Desktop
if ! command -v docker &> /dev/null; then
    echo "📦 Docker not found. Please install Docker Desktop manually from:"
    echo "   https://www.docker.com/products/docker-desktop"
    echo "   Then re-run this script."
    exit 1
else
    echo "✅ Docker already installed"
fi

# Verify Git is installed (comes with Xcode Command Line Tools)
if ! command -v git &> /dev/null; then
    echo "📦 Installing Git (via Xcode Command Line Tools)..."
    xcode-select --install
    echo "⚠️  Please complete the Xcode installation and re-run this script"
    exit 1
else
    echo "✅ Git already installed"
fi

echo ""
echo "✨ System dependencies installed successfully!"
echo ""
echo "Next steps:"
echo "  1. Clone the repository"
echo "  2. Copy .env.example to .env and configure environment variables"
echo "  3. Run: npm install"
echo "  4. Run: npm run db:generate"
echo "  5. Run: npm run db:push"
echo "  6. Run: npm run dev"
echo ""