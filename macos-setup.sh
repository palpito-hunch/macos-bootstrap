#!/bin/bash
#
# macOS Setup Script
# Bootstraps a new macOS machine with development tools and AI coding assistants
#

set -e  # Exit on error

SETUP_TYPE=""  # Will be set to "docker" or "local"

echo "🚀 Setting up macOS development environment..."
echo ""

# =============================================================================
# Xcode Command Line Tools
# =============================================================================
echo "📦 Checking Xcode Command Line Tools..."
if ! xcode-select -p &> /dev/null; then
    echo "   Installing Xcode Command Line Tools..."
    xcode-select --install
    echo ""
    echo "⚠️  Please complete the Xcode installation dialog and re-run this script"
    exit 1
else
    echo "✅ Xcode Command Line Tools already installed"
fi

# =============================================================================
# Homebrew
# =============================================================================
echo ""
echo "📦 Checking Homebrew..."
if ! command -v brew &> /dev/null; then
    echo "   Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "✅ Homebrew already installed"
fi

# =============================================================================
# Setup Type Selection
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Choose your development environment setup:"
echo ""
echo "  [1] Docker (Recommended)"
echo "      • Best for Apple Silicon (M1/M2/M3) with 16GB+ RAM"
echo "      • Best for Intel Macs with 32GB+ RAM"
echo "      • Isolated, consistent environments"
echo ""
echo "  [2] Local"
echo "      • Best for Intel Macs with 8-16GB RAM"
echo "      • Lower resource usage (~35-65 MB vs ~2 GB)"
echo "      • Better performance on limited hardware"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

while true; do
    read -p "Enter your choice [1/2]: " choice
    case $choice in
        1)
            SETUP_TYPE="docker"
            echo ""
            echo "✅ Selected: Docker setup"
            break
            ;;
        2)
            SETUP_TYPE="local"
            echo ""
            echo "✅ Selected: Local setup"
            break
            ;;
        *)
            echo "Please enter 1 or 2"
            ;;
    esac
done

# =============================================================================
# CLI Tools via Homebrew
# =============================================================================
echo ""
echo "📦 Installing CLI tools..."

CLI_TOOLS=(
    "git"
    "gh"
    "node"
)

for tool in "${CLI_TOOLS[@]}"; do
    if command -v "$tool" &> /dev/null; then
        echo "✅ $tool already installed"
    elif brew list "$tool" &> /dev/null 2>&1; then
        echo "✅ $tool already installed via brew"
    else
        echo "   Installing $tool..."
        brew install "$tool" || echo "⚠️  Failed to install $tool, continuing..."
    fi
done

# Verify npm is available (bundled with node)
if command -v npm &> /dev/null; then
    echo "✅ npm already installed (bundled with node)"
else
    echo "⚠️  npm not found - reinstalling node..."
    brew reinstall node || echo "⚠️  Failed to reinstall node, continuing..."
fi

# =============================================================================
# Cask Applications
# =============================================================================
echo ""
echo "📦 Installing applications..."

CASK_APPS=(
    "sublime-text"
    "slack"
    "macdown"
    "kiro"
)

for app in "${CASK_APPS[@]}"; do
    if brew list --cask "$app" &> /dev/null 2>&1; then
        echo "✅ $app already installed"
    else
        echo "   Installing $app..."
        if ! brew install --cask "$app" 2>&1; then
            echo "⚠️  Failed to install $app (may already be installed outside Homebrew), continuing..."
        fi
    fi
done

# =============================================================================
# Development Environment (Docker or Local)
# =============================================================================
echo ""
if [ "$SETUP_TYPE" = "docker" ]; then
    echo "📦 Setting up Docker environment..."

    # Install Docker Desktop
    if brew list --cask docker &> /dev/null 2>&1; then
        echo "✅ Docker Desktop already installed"
    else
        echo "   Installing Docker Desktop..."
        if ! brew install --cask docker 2>&1; then
            echo "⚠️  Failed to install Docker Desktop (may already be installed outside Homebrew), continuing..."
        fi
    fi

    echo ""
    echo "ℹ️  After setup, start Docker Desktop from Applications"
    echo "   Then use 'npm run docker:up' in your project to start services"

elif [ "$SETUP_TYPE" = "local" ]; then
    echo "📦 Setting up local environment..."

    # Install PostgreSQL 16
    if brew list postgresql@16 &> /dev/null 2>&1; then
        echo "✅ PostgreSQL 16 already installed"
    else
        echo "   Installing PostgreSQL 16..."
        brew install postgresql@16 || echo "⚠️  Failed to install PostgreSQL 16, continuing..."
    fi

    # Start PostgreSQL service
    echo "   Starting PostgreSQL service..."
    brew services start postgresql@16 2>/dev/null || echo "✅ PostgreSQL service already running"

    # Install Redis
    if brew list redis &> /dev/null 2>&1; then
        echo "✅ Redis already installed"
    else
        echo "   Installing Redis..."
        brew install redis || echo "⚠️  Failed to install Redis, continuing..."
    fi

    # Start Redis service
    echo "   Starting Redis service..."
    brew services start redis 2>/dev/null || echo "✅ Redis service already running"

    echo ""
    echo "✅ PostgreSQL and Redis services started"
fi

# =============================================================================
# Claude CLI
# =============================================================================
echo ""
echo "📦 Checking Claude CLI..."
if command -v claude &> /dev/null; then
    echo "✅ Claude CLI already installed"
else
    echo "   Installing Claude CLI..."
    npm install -g @anthropic-ai/claude-code || echo "⚠️  Failed to install Claude CLI, continuing..."
fi

# =============================================================================
# Authenticate GitHub CLI
# =============================================================================
echo ""
echo "📦 Checking GitHub CLI authentication..."
if ! gh auth status &> /dev/null 2>&1; then
    echo "   Please authenticate with GitHub:"
    gh auth login
else
    echo "✅ GitHub CLI already authenticated"
fi

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "=============================================="
echo "✨ macOS development environment setup complete!"
echo "=============================================="
echo ""
echo "Installed:"
echo "  • Xcode Command Line Tools"
echo "  • Homebrew"
echo "  • CLI tools: git, gh, node, npm"
echo "  • Apps: Sublime Text, Slack, MacDown, Kiro"
echo "  • Claude CLI"
if [ "$SETUP_TYPE" = "docker" ]; then
    echo "  • Docker Desktop"
elif [ "$SETUP_TYPE" = "local" ]; then
    echo "  • PostgreSQL 16 (running as service)"
    echo "  • Redis (running as service)"
fi
echo ""
echo "Next steps:"
echo "  1. Restart your terminal to ensure PATH updates take effect"
echo "  2. Run 'claude' to start using Claude Code"
if [ "$SETUP_TYPE" = "docker" ]; then
    echo "  3. Start Docker Desktop from Applications"
    echo "  4. Clone your project and run 'npm run docker:up'"
elif [ "$SETUP_TYPE" = "local" ]; then
    echo "  3. Clone your project and configure .env with local connection strings"
    echo "  4. Run 'npm install && npm run db:push'"
fi
echo ""
