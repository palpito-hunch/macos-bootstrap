#!/bin/bash
#
# macOS Setup Script
# Bootstraps a new macOS machine with development tools and AI coding assistants
#

set -e  # Exit on error

ORG="palpito-hunch"
TEMPLATES_DIR="$HOME/.templates"
AI_RULES_DIR="$HOME/.ai-rules"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
PLIST_NAME="com.palpito.ai-rules-update.plist"

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
echo ""
echo "Cloned repositories:"
echo "  • ai-rules -> $AI_RULES_DIR"
echo "  • backend-template -> $TEMPLATES_DIR/backend-template"
echo "  • frontend-template -> $TEMPLATES_DIR/frontend-template"
echo ""
echo "Auto-update:"
echo "  • ai-rules will auto-update on login"
echo "  • Logs: $AI_RULES_DIR/.git-pull.log"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal to ensure PATH updates take effect"
echo "  2. Run 'claude' to start using Claude Code"
echo ""
