# System Update Harness — Implementation Plan

Date: 2026-04-04
Spec: `docs/superpowers/specs/2026-04-04-system-update-harness-design.md`
Status: in progress

---

## Tasks

### #23 — Create `bin/update.sh.tmpl`

**File:** `bin/update.sh.tmpl`

```bash
#!/usr/bin/env bash
# Unified update script — all package layers
# Installed to ~/.local/bin/update
set -e

echo "═══════════════════════════════════════"
echo "  System Update"
echo "═══════════════════════════════════════"

echo "→ Dotfiles..."
chezmoi update

echo "→ Homebrew..."
brew update && brew upgrade

echo "→ System packages..."
{{- if eq .flavor "fedora-atomic" }}
ujust update
{{- else if eq .flavor "fedora" }}
sudo dnf update -y
{{- else if eq .flavor "arch" }}
sudo pacman -Sy archlinux-keyring && paru -Syu --noconfirm
{{- else if eq .flavor "debian" }}
sudo apt update && sudo apt upgrade -y
{{- end }}

echo "→ Runtimes..."
cargo install-update -a 2>/dev/null || true
bun update --global 2>/dev/null || true
pnpm update -g 2>/dev/null || true

echo "═══════════════════════════════════════"
echo "  ✓ All layers updated"
echo "═══════════════════════════════════════"
```

**Note:** `{{- ... -}}` trims surrounding whitespace so the template output is clean.

---

### #24 — Create `run_once_000-system-update.sh.tmpl`

**File:** `.chezmoiscripts/run_once_000-system-update.sh.tmpl`

```bash
#!/bin/bash
{{ if eq .chezmoi.os "darwin" }}exit 0{{ end }}
# Install update script and run initial system update
set -e

echo "Installing update script..."
mkdir -p "$HOME/.local/bin"
install -m 755 "$HOME/dotfiles/bin/update.sh" "$HOME/.local/bin/update"
echo "✓ Update script installed to ~/.local/bin/update"

echo "Running initial system update..."
"$HOME/.local/bin/update"
```

**Numbering `000-` ensures it runs first**, before all other `run_once_*` scripts.

---

### #25 — Add `alias update` to `aliases.zsh`

**File:** `private_dot_config/zsh/aliases.zsh`

Add after the existing alias block:
```zsh
# ============================================
# SYSTEM UPDATE
# ============================================
alias update='~/.local/bin/update'
```

---

## Verification

After implementation, `chezmoi apply` should:
1. Install `~/.local/bin/update` from `bin/update.sh.tmpl`
2. Run the initial system update (first-boot freshness)
3. Make `update` available as a shell alias

---

## Commit

Single commit: "feat: add unified system update harness"
