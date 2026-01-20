#!/bin/bash
#
# macOS Setup Script
# Bootstraps a new macOS machine with development tools and AI coding assistants
#
# Usage:
#   ./macos-setup.sh              # Full install (software + aliases)
#   ./macos-setup.sh --aliases    # Only update shell aliases/commands
#   ./macos-setup.sh --software   # Only install/update software
#   ./macos-setup.sh --help       # Show help
#

set -e  # Exit on error

# Mode flags
INSTALL_SOFTWARE=false
INSTALL_ALIASES=false

# Parse arguments
if [ $# -eq 0 ]; then
    # No arguments = do everything
    INSTALL_SOFTWARE=true
    INSTALL_ALIASES=true
else
    for arg in "$@"; do
        case $arg in
            --aliases|-a)
                INSTALL_ALIASES=true
                ;;
            --software|-s)
                INSTALL_SOFTWARE=true
                ;;
            --all)
                INSTALL_SOFTWARE=true
                INSTALL_ALIASES=true
                ;;
            --help|-h)
                echo "macOS Setup Script"
                echo ""
                echo "Usage:"
                echo "  ./macos-setup.sh              Full install (software + aliases)"
                echo "  ./macos-setup.sh --aliases    Only update shell aliases/commands"
                echo "  ./macos-setup.sh --software   Only install/update software"
                echo "  ./macos-setup.sh --all        Same as no arguments"
                echo "  ./macos-setup.sh --help       Show this help"
                echo ""
                echo "Short flags: -a (aliases), -s (software), -h (help)"
                exit 0
                ;;
            *)
                echo "Unknown option: $arg"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
fi

SETUP_TYPE=""  # Will be set to "docker", "local", or "both"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORG="palpito-hunch"
TEMPLATES_DIR="$HOME/.templates"
AI_RULES_DIR="$HOME/.ai-rules"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
PLIST_NAME="com.palpito.ai-rules-update.plist"

echo "🚀 Setting up macOS development environment..."
echo ""

if [ "$INSTALL_SOFTWARE" = true ]; then

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
if [ "$INSTALL_SOFTWARE" = true ]; then
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
    echo "  [3] Both"
    echo "      • Install Docker Desktop AND local PostgreSQL/Redis"
    echo "      • Maximum flexibility"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    while true; do
        read -p "Enter your choice [1/2/3]: " choice
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
            3)
                SETUP_TYPE="both"
                echo ""
                echo "✅ Selected: Both Docker and Local"
                break
                ;;
            *)
                echo "Please enter 1, 2, or 3"
                ;;
        esac
    done
fi

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

# Install Docker if selected
if [ "$SETUP_TYPE" = "docker" ] || [ "$SETUP_TYPE" = "both" ]; then
    echo "📦 Setting up Docker environment..."

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
fi

# Install Local services if selected
if [ "$SETUP_TYPE" = "local" ] || [ "$SETUP_TYPE" = "both" ]; then
    echo ""
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

fi  # End INSTALL_SOFTWARE

# =============================================================================
# Service Control Scripts (Aliases)
# =============================================================================
if [ "$INSTALL_ALIASES" = true ]; then
    echo ""
    echo "📦 Installing service control scripts..."

    DEV_SERVICES_SRC="$SCRIPT_DIR/dev-services.sh"
    DEV_SERVICES_DEST="$HOME/.dev-services.sh"

    # Copy dev-services.sh to home directory
    if [ -f "$DEV_SERVICES_SRC" ]; then
        cp "$DEV_SERVICES_SRC" "$DEV_SERVICES_DEST"
        echo "   Copied dev-services.sh to $DEV_SERVICES_DEST"
    else
        # If running via curl, download the file
        echo "   Downloading dev-services.sh..."
        curl -fsSL https://raw.githubusercontent.com/palpito-hunch/macos-bootstrap/main/dev-services.sh -o "$DEV_SERVICES_DEST" || echo "⚠️  Failed to download dev-services.sh, continuing..."
    fi

    # Add source line to shell config if not present
    SHELL_CONFIG=""
    if [ -f "$HOME/.zshrc" ]; then
        SHELL_CONFIG="$HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then
        SHELL_CONFIG="$HOME/.bashrc"
    fi

    if [ -n "$SHELL_CONFIG" ] && [ -f "$DEV_SERVICES_DEST" ]; then
        if ! grep -q "source.*\.dev-services\.sh" "$SHELL_CONFIG" 2>/dev/null; then
            echo "" >> "$SHELL_CONFIG"
            echo "# Development service controls" >> "$SHELL_CONFIG"
            echo "source \"\$HOME/.dev-services.sh\"" >> "$SHELL_CONFIG"
            echo "   Added source line to $SHELL_CONFIG"
        else
            echo "✅ Shell config already sources dev-services.sh"
        fi
    fi

    echo "✅ Service control scripts installed (run 'services_help' for commands)"
fi  # End INSTALL_ALIASES

if [ "$INSTALL_SOFTWARE" = true ]; then

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
# Organization Repositories
# =============================================================================
echo ""
echo "📦 Setting up organization repositories..."

# Create templates directory
if [ ! -d "$TEMPLATES_DIR" ]; then
    echo "   Creating $TEMPLATES_DIR..."
    mkdir -p "$TEMPLATES_DIR"
fi

# Clone ai-rules
if [ -d "$AI_RULES_DIR" ]; then
    echo "✅ ai-rules already cloned"
else
    echo "   Cloning ai-rules to $AI_RULES_DIR..."
    gh repo clone "$ORG/ai-rules" "$AI_RULES_DIR" || echo "⚠️  Failed to clone ai-rules, continuing..."
fi

# Clone backend-template
if [ -d "$TEMPLATES_DIR/backend-template" ]; then
    echo "✅ backend-template already cloned"
else
    echo "   Cloning backend-template to $TEMPLATES_DIR/backend-template..."
    gh repo clone "$ORG/backend-template" "$TEMPLATES_DIR/backend-template" || echo "⚠️  Failed to clone backend-template, continuing..."
fi

# Clone frontend-template
if [ -d "$TEMPLATES_DIR/frontend-template" ]; then
    echo "✅ frontend-template already cloned"
else
    echo "   Cloning frontend-template to $TEMPLATES_DIR/frontend-template..."
    gh repo clone "$ORG/frontend-template" "$TEMPLATES_DIR/frontend-template" || echo "⚠️  Failed to clone frontend-template, continuing..."
fi

# =============================================================================
# Run ai-rules install script
# =============================================================================
echo ""
echo "📦 Running ai-rules install script..."
if [ -f "$AI_RULES_DIR/scripts/install.sh" ]; then
    bash "$AI_RULES_DIR/scripts/install.sh"
else
    echo "⚠️  ai-rules install script not found at $AI_RULES_DIR/scripts/install.sh"
fi

# =============================================================================
# Launchd Agent for ai-rules auto-update
# =============================================================================
echo ""
echo "📦 Setting up ai-rules auto-update on login..."

# Create LaunchAgents directory if needed
if [ ! -d "$LAUNCH_AGENTS_DIR" ]; then
    mkdir -p "$LAUNCH_AGENTS_DIR"
fi

PLIST_PATH="$LAUNCH_AGENTS_DIR/$PLIST_NAME"

# Create the plist file
cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.palpito.ai-rules-update</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/git</string>
        <string>-C</string>
        <string>${AI_RULES_DIR}</string>
        <string>pull</string>
        <string>--ff-only</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>StartInterval</key>
    <integer>3600</integer>
    <key>StandardOutPath</key>
    <string>${AI_RULES_DIR}/.git-pull.log</string>
    <key>StandardErrorPath</key>
    <string>${AI_RULES_DIR}/.git-pull.log</string>
</dict>
</plist>
EOF

echo "   Created $PLIST_PATH"

# Load the agent
launchctl unload "$PLIST_PATH" 2>/dev/null || true
if launchctl load "$PLIST_PATH" 2>/dev/null; then
    echo "✅ Launchd agent loaded"
else
    echo "✅ Launchd agent already loaded or updated"
fi

fi  # End INSTALL_SOFTWARE (second block)

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "=============================================="
echo "✨ Setup complete!"
echo "=============================================="
echo ""

if [ "$INSTALL_SOFTWARE" = true ]; then
    echo "Software installed:"
    echo "  • Xcode Command Line Tools"
    echo "  • Homebrew"
    echo "  • CLI tools: git, gh, node, npm"
    echo "  • Apps: Sublime Text, Slack, MacDown, Kiro"
    echo "  • Claude CLI"
    if [ "$SETUP_TYPE" = "docker" ] || [ "$SETUP_TYPE" = "both" ]; then
        echo "  • Docker Desktop"
    fi
    if [ "$SETUP_TYPE" = "local" ] || [ "$SETUP_TYPE" = "both" ]; then
        echo "  • PostgreSQL 16 (running as service)"
        echo "  • Redis (running as service)"
    fi
    echo ""
    echo "Cloned repositories:"
    echo "  • ai-rules -> $AI_RULES_DIR"
    echo "  • backend-template -> $TEMPLATES_DIR/backend-template"
    echo "  • frontend-template -> $TEMPLATES_DIR/frontend-template"
    echo ""
    echo "Auto-update:"
    echo "  • ai-rules will auto-update on login and every hour"
    echo "  • Logs: $AI_RULES_DIR/.git-pull.log"
    echo ""
fi

if [ "$INSTALL_ALIASES" = true ]; then
    echo "Shell commands installed:"
    echo "  • ~/.dev-services.sh (sourced in shell config)"
    echo "  • Run 'services_help' to see all commands"
    echo ""
fi

echo "Next steps:"
echo "  1. Restart your terminal to load new commands"
if [ "$INSTALL_SOFTWARE" = true ]; then
    echo "  2. Run 'claude' to start using Claude Code"
    if [ "$SETUP_TYPE" = "docker" ]; then
        echo "  3. Start Docker Desktop from Applications"
    elif [ "$SETUP_TYPE" = "local" ]; then
        echo "  3. Run 'services_help' to see service control commands"
    elif [ "$SETUP_TYPE" = "both" ]; then
        echo "  3. Start Docker Desktop or use 'services_help' for local services"
    fi
fi
echo ""
