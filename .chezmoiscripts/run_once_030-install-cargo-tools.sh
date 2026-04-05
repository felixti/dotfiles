#!/usr/bin/env bash
# Install Rust-based tools via cargo
set -euo pipefail
command -v cargo &>/dev/null || { echo "cargo not found, skipping"; exit 0; }

if ! command -v yazi &>/dev/null; then
    echo "Installing yazi..."
    cargo install --locked yazi-fm yazi-cli
    echo "✓ yazi installed"
fi
