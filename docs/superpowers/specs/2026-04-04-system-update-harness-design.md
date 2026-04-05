# System Update Harness — Design

Date: 2026-04-04
Status: approved

---

## Overview

A unified `update` command that refreshes all package layers on any supported distro: OS packages, Homebrew, chezmoi dotfiles, and language runtimes (cargo, bun, pnpm). Runs both as an initial setup step and as a day-to-day command.

---

## Components

### 1. `run_once_000-system-update.sh.tmpl`

First-boot script — runs automatically on `chezmoi apply`. Installs the update script and runs it once.

```bash
#!/bin/bash
{{ if eq .chezmoi.os "darwin" }}exit 0{{ end }}
set -e

mkdir -p "$HOME/.local/bin"
install -m 755 "$HOME/dotfiles/bin/update.sh" "$HOME/.local/bin/update"

"$HOME/.local/bin/update"
```

### 2. `bin/update.sh.tmpl`

Portable script installed to `~/.local/bin/update`. Handles all layers:

| Layer | Fedora Atomic | Fedora | Arch | Debian | macOS |
|---|---|---|---|---|---|
| Dotfiles | `chezmoi update` | same | same | same | same |
| Homebrew | `brew update && brew upgrade` | same | same | same | same |
| System | `ujust update` | `sudo dnf update -y` | `pacman -Sy archlinux-keyring && paru -Syu` | `apt update && apt upgrade -y` | n/a |
| Runtimes | `cargo install-update -a && bun update --global && pnpm update -g` | same | same | same | same |

- `|| true` on runtimes prevents cascade failure if a runtime isn't installed
- `archlinux-keyring` refreshed before pacman to prevent signature errors
- `paru` used on Arch (not pacman) — matches the AUR setup

### 3. `private_dot_config/zsh/aliases.zsh`

Adds alias:
```zsh
alias update='~/.local/bin/update'
```

---

## File Layout

```
bin/
└── update.sh.tmpl              # main update script (templated)

.chezmoiscripts/
└── run_once_000-system-update.sh.tmpl  # installs + runs update once

private_dot_config/zsh/
└── aliases.zsh                  # add 'update' alias
```

---

## Sources

- [Aurora Basic Usage — ujust update](https://docs.getaurora.dev/guides/basic-usage/)
- [Bluefin ujust](https://github.com/ublue-os/bluefin)
- [Issue #196 — ujust update flatpaks](https://github.com/ublue-os/aurora/issues/196)
