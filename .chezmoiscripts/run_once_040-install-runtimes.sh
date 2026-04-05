#!/usr/bin/env bash
# Install language runtime managers
set -euo pipefail

# Retry wrapper for critical downloads
download_with_retry() {
    local cmd="$1"
    local desc="$2"
    for i in {1..3}; do
        echo "Attempting $desc (attempt $i)..."
        if eval "$cmd"; then
            return 0
        fi
        echo "$desc failed, retrying..."
        sleep 2
    done
    echo "ERROR: $desc failed after 3 attempts"
    return 1
}

if [ ! -d "$HOME/.nvm" ]; then
    echo "Installing nvm..."
    download_with_retry 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash' "nvm installation"
    echo "✓ nvm installed"
fi

if ! command -v rustup &>/dev/null; then
    echo "Installing rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    echo "✓ rustup installed"
fi

if ! command -v bun &>/dev/null; then
    echo "Installing bun..."
    download_with_retry 'curl -fsSL https://bun.sh/install | bash' "bun installation"
    echo "✓ bun installed"
fi

if ! command -v uv &>/dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    echo "✓ uv installed"
fi
