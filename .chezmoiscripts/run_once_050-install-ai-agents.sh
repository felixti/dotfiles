#!/usr/bin/env bash
# Install AI coding agents via npm
set -euo pipefail

export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    source "$NVM_DIR/nvm.sh"
else
    echo "ERROR: nvm not found at $NVM_DIR — run install-runtimes first"
    exit 1
fi

if ! command -v claude &>/dev/null; then
    echo "Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code
    echo "✓ claude installed"
fi

if ! command -v codex &>/dev/null; then
    echo "Installing Codex..."
    npm install -g @openai/codex
    echo "✓ codex installed"
fi

if ! command -v opencode &>/dev/null; then
    echo "Installing opencode..."
    npm install -g opencode-ai
    echo "✓ opencode installed"
fi
