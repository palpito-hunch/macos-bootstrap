#!/bin/bash
#
# Bootstrap script - downloads and runs macos-setup.sh
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/palpito-hunch/macos-bootstrap/main/bootstrap.sh | bash
#
# This script:
#   1. Downloads the macos-bootstrap repo to a temp directory
#   2. Runs macos-setup.sh (which has full terminal access)
#   3. Cleans up the temp directory
#

set -e

REPO_URL="https://github.com/palpito-hunch/macos-bootstrap.git"
TEMP_DIR=$(mktemp -d)

cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "📥 Downloading macos-bootstrap..."
git clone --depth 1 "$REPO_URL" "$TEMP_DIR" 2>/dev/null || {
    echo "❌ Failed to clone repo. Make sure git is installed."
    echo "   Install Xcode Command Line Tools: xcode-select --install"
    exit 1
}

echo "🚀 Running setup script..."
echo ""

# Run the script with all passed arguments
cd "$TEMP_DIR"
bash macos-setup.sh "$@"
