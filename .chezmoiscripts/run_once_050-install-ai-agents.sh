#!/bin/bash
# Install AI coding agents via npm
set -e

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

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
