# Dotfiles & Machine Reproducibility — Chezmoi Design

**Date:** 2026-04-04
**Author:** Felipe Felix (felixti)
**Repo:** `github.com/felixti/dotfiles`
**Tool:** [chezmoi](https://chezmoi.io) v2

---

## Overview

A reproducible, multi-flavor dotfiles system managed by chezmoi. A single repository covers all personal machines regardless of distro or desktop environment. Any new machine is fully configured by running one command.

```bash
sh -c "$(curl -fsLS get.chezmoi.io)"
chezmoi init --apply gh:felixti/dotfiles
```

---

## Flavor System (2D)

Configuration is parameterized on two independent axes, set once per machine during `chezmoi init` and stored locally in `~/.config/chezmoi/chezmoi.toml`.

### `flavor` — distro type

| Value | Distros | Package manager |
|---|---|---|
| `fedora-atomic` | Bluefin, Aurora | `rpm-ostree` + `flatpak` + Homebrew |
| `arch` | Arch Linux, CachyOS | `pacman` + `paru` (AUR) + Homebrew |
| `debian` | Ubuntu, Debian, Pop!_OS | `apt` + Homebrew |
| `macos` | macOS | Homebrew |

### `de` — desktop environment

| Value | Use case |
|---|---|
| `gnome` | Bluefin, Ubuntu, Arch+GNOME |
| `kde` | Aurora, CachyOS KDE, Arch+KDE |
| `hyprland` | Arch+Hyprland, CachyOS+Hyprland |
| `none` | Headless / server / macOS |

Valid combinations include any `flavor × de` pair. macOS always uses `de = none`.

---

## Repository Structure

```
dotfiles/
├── .chezmoi.toml.tmpl              # Bootstrap wizard — prompts flavor, de, identity, secrets
├── .chezmoiignore                  # 2D conditional file exclusion (flavor × de)
├── .chezmoiexternal.toml           # External sources: antidote, tpm, etc.
├── secrets.example.toml            # Committed — documents all secret keys, zero values
│
├── dot_zshrc.tmpl                  # ~/.zshrc
├── dot_gitconfig.tmpl              # ~/.gitconfig
├── dot_zprofile                    # ~/.zprofile
├── dot_bash_profile                # ~/.bash_profile
├── dot_bashrc                      # ~/.bashrc
├── dot_yarnrc                      # ~/.yarnrc
└── dot_zsh_plugins.txt             # ~/.zsh_plugins.txt
│
├── dot_config/
│   │
│   ├── # ── CROSS-PLATFORM (all flavors × all DE) ──────────────────────────
│   ├── zsh/
│   │   ├── main.zsh                # Loader — sources all modules
│   │   ├── aliases.zsh             # eza, bat, fd, rg, zoxide, docker, tailscale
│   │   ├── env.zsh.tmpl            # PATH — brew/cargo paths differ per flavor/OS
│   │   ├── functions.zsh           # yy(), fe(), fif(), _zoxide_hook_and_ls()
│   │   ├── tools.zsh.tmpl          # starship/zoxide/fzf/thefuck/tv inits
│   │   ├── tmux-helpers.zsh        # tmux session helpers
│   │   ├── starship-themes.zsh     # theme switcher function
│   │   └── completions/            # _bat, _eza, _fd, _rg, _tailscale, _yazi
│   │
│   ├── tmux/
│   │   ├── tmux.conf               # Main config (symlinked from ~/.tmux.conf)
│   │   ├── keybindings.conf
│   │   ├── plugins.conf
│   │   └── settings.conf
│   │
│   ├── nvim/
│   │   ├── init.lua                # AstroNvim entry point
│   │   ├── lazy-lock.json          # Pinned plugin versions — reproducible
│   │   └── lua/
│   │       ├── community.lua
│   │       ├── lazy_setup.lua
│   │       ├── plugins/            # astrocore, astrolsp, astroui, mason, etc.
│   │       └── polish.lua
│   │
│   ├── starship/
│   │   ├── cyber.toml
│   │   ├── developer.toml
│   │   └── minimal.toml
│   ├── starship.toml               # Active theme (root-level override)
│   │
│   ├── ghostty/                    # Cross-platform terminal (Linux + macOS)
│   │   ├── config
│   │   └── config.ghostty
│   ├── kitty/kitty.conf            # Cross-platform terminal
│   ├── yazi/                       # File manager: yazi.toml, keymap, init.lua, theme
│   ├── television/config.toml      # Fuzzy TUI with custom shell integration
│   ├── btop/btop.conf
│   ├── glow/glow.yml
│   ├── thefuck/settings.py
│   └── gh/config.yml               # gh CLI — NOT hosts.yml (contains tokens)
│
│   ├── # ── DE: GNOME ── (.chezmoiignore excludes if .de != "gnome") ───────
│   ├── pop-shell/config.json       # Tiling extension config
│   ├── gtk-3.0/settings.ini
│   ├── gtk-4.0/settings.ini
│   └── org.gnome.Ptyxis/           # GNOME terminal config
│
│   ├── # ── DE: HYPRLAND ── (.chezmoiignore excludes if .de != "hyprland") ─
│   ├── hypr/hyprland.conf          # Main Hyprland config
│   ├── waybar/                     # Status bar
│   ├── rofi/                       # App launcher
│   ├── dunst/                      # Notifications
│   └── hyprlock/                   # Lock screen
│
│   └── # ── DE: KDE ── (.chezmoiignore excludes if .de != "kde") ──────────
│       ├── kdeglobals
│       ├── kwinrc
│       └── plasma-*/
│
├── .chezmoiscripts/
│   │
│   ├── # ── COMMON (runs on all flavors) ────────────────────────────────────
│   ├── run_once_010-install-homebrew.sh.tmpl
│   ├── run_once_020-install-cli-tools.sh.tmpl     # eza,bat,fd,fzf,rg,zoxide,starship,lazygit,glow,tv,thefuck
│   ├── run_once_030-install-cargo-tools.sh        # yazi, yazi-cli
│   ├── run_once_040-install-runtimes.sh           # nvm, bun, rustup, uv
│   ├── run_once_050-install-ai-agents.sh.tmpl     # claude-code, codex, opencode
│   │
│   ├── # ── DISTRO: fedora-atomic ────────────────────────────────────────────
│   ├── run_once_060-fedora-tailscale.sh.tmpl      # migrated from Temp/install-tailscale-quick.sh
│   ├── run_once_061-fedora-flatpaks.sh.tmpl       # flatpak remotes + core apps
│   ├── run_onchange_fedora-security.sh.tmpl       # migrated from Temp/security-hardening.sh
│   │
│   ├── # ── DISTRO: arch ─────────────────────────────────────────────────────
│   ├── run_once_060-arch-paru.sh.tmpl             # install paru AUR helper
│   ├── run_once_061-arch-packages.sh.tmpl         # pacman + AUR packages (works for CachyOS)
│   │
│   ├── # ── DE: gnome ────────────────────────────────────────────────────────
│   ├── run_once_080-gnome-catppuccin.sh.tmpl      # migrated from Temp/setup-catppuccin-gnome49.sh
│   ├── run_once_081-gnome-extensions.sh.tmpl      # tiling-shell, pop-shell setup
│   ├── run_once_082-gnome-dconf.sh.tmpl           # dconf load — keybindings, workspace, prefs
│   │
│   ├── # ── DE: hyprland ─────────────────────────────────────────────────────
│   ├── run_once_080-hyprland-deps.sh.tmpl         # waybar, rofi, dunst, hyprlock, swayidle
│   │
│   └── # ── DE: kde ──────────────────────────────────────────────────────────
│       └── run_once_080-kde-catppuccin.sh.tmpl
│
└── ai-agents/
    ├── secrets.example.toml                       # Committed — structure only
    ├── private_dot_claude.json.tmpl               # ~/.claude.json (600 perms)
    └── dot_config/
        └── opencode/
            └── opencode.json.tmpl                 # ~/.config/opencode/opencode.json
```

---

## Template Strategy

### Bootstrap wizard — `.chezmoi.toml.tmpl`

Runs once on `chezmoi init`. Saves answers to `~/.config/chezmoi/chezmoi.toml` (local, gitignored). Subsequent `chezmoi apply` reads silently.

```toml
{{- $flavor   := promptStringOnce . "flavor"         "Distro flavor (fedora-atomic/arch/debian/macos)" -}}
{{- $de       := promptStringOnce . "de"             "Desktop env (gnome/kde/hyprland/none)" -}}
{{- $name     := promptStringOnce . "gitName"        "Git full name" -}}
{{- $email    := promptStringOnce . "gitEmail"       "Git email" -}}
{{- $anthropic := promptStringOnce . "anthropicApiKey" "Anthropic API key (blank to skip)" -}}
{{- $openai   := promptStringOnce . "openaiApiKey"   "OpenAI API key (blank to skip)" -}}
{{- $kimi     := promptStringOnce . "kimiApiKey"     "Kimi API key (blank to skip)" -}}

[data]
  flavor          = {{ $flavor   | quote }}
  de              = {{ $de       | quote }}
  gitName         = {{ $name     | quote }}
  gitEmail        = {{ $email    | quote }}
  anthropicApiKey = {{ $anthropic | quote }}
  openaiApiKey    = {{ $openai   | quote }}
  kimiApiKey      = {{ $kimi     | quote }}
```

### `.chezmoiignore` — 2D conditional exclusion

```
{{/* DE-specific configs */}}
{{ if ne .de "gnome" }}
dot_config/pop-shell
dot_config/gtk-3.0
dot_config/gtk-4.0
dot_config/org.gnome.Ptyxis
{{ end }}

{{ if ne .de "hyprland" }}
dot_config/hypr
dot_config/waybar
dot_config/rofi
dot_config/dunst
dot_config/hyprlock
{{ end }}

{{ if ne .de "kde" }}
dot_config/kdeglobals
dot_config/kwinrc
{{ end }}
```

### `env.zsh.tmpl` — flavor-aware PATH

```bash
# Homebrew prefix differs: /opt/homebrew (macOS) vs /home/linuxbrew/.linuxbrew (Linux)
{{- if eq .chezmoi.os "darwin" }}
eval "$(/opt/homebrew/bin/brew shellenv)"
{{- else }}
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
{{- end }}

# .NET — only fedora-atomic ships it natively
{{- if eq .flavor "fedora-atomic" }}
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH"
{{- end }}

# Runtimes (universal — guarded by existence)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.bun/bin:$PATH"
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# LM Studio (Linux only)
{{- if ne .chezmoi.os "darwin" }}
export PATH="$PATH:$HOME/.lmstudio/bin"
{{- end }}
```

### `dot_gitconfig.tmpl`

```ini
[user]
  name  = {{ .gitName }}
  email = {{ .gitEmail }}

[credential "https://github.com"]
  helper =
  helper = !/home/linuxbrew/.linuxbrew/bin/gh auth git-credential

[core]
  editor = nvim
```

### Scripts — guard pattern

Every distro/DE script exits early when not applicable:

```bash
#!/bin/bash
# run_once_060-fedora-tailscale.sh.tmpl
{{ if ne .flavor "fedora-atomic" }}exit 0{{ end }}
# ... rest of script
```

---

## Secrets Strategy (A — Template + Local Config)

### Flow

```
COMMITTED (repo):
  secrets.example.toml          ← structure + comments, zero values

LOCAL ONLY (gitignored):
  ~/.config/chezmoi/chezmoi.toml ← real values, written by chezmoi init wizard

RENDERED AT APPLY TIME:
  ~/.claude.json                 ← from private_dot_claude.json.tmpl
  ~/.config/opencode/opencode.json
```

### `secrets.example.toml` (committed)

```toml
# This file documents the secrets chezmoi init will ask for.
# Real values live in ~/.config/chezmoi/chezmoi.toml — never committed.

[data]
  flavor          = "fedora-atomic"   # fedora-atomic | arch | debian | macos
  de              = "gnome"           # gnome | kde | hyprland | none
  gitName         = ""
  gitEmail        = ""
  anthropicApiKey = ""                # Claude Code / Anthropic API
  openaiApiKey    = ""                # Codex / OpenCode
  kimiApiKey      = ""                # Kimi Code
```

### AI agent templates

```json
// ai-agents/private_dot_claude.json.tmpl  → ~/.claude.json (mode 600)
{
  "api_key": "{{ .anthropicApiKey }}"
}
```

```json
// ai-agents/dot_config/opencode/opencode.json.tmpl
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": ["oh-my-openagent@latest"]
  {{ if .openaiApiKey }},
  "api_key": "{{ .openaiApiKey }}"
  {{ end }}
}
```

The `private_` prefix sets `600` permissions automatically — no extra steps needed.

---

## Bootstrap Scripts — Full Order

| Script | Trigger | Scope |
|---|---|---|
| `010-install-homebrew` | `run_once_` | all |
| `020-install-cli-tools` | `run_once_` | all |
| `030-install-cargo-tools` | `run_once_` | all |
| `040-install-runtimes` | `run_once_` | all |
| `050-install-ai-agents` | `run_once_` | all |
| `060-fedora-tailscale` | `run_once_` | fedora-atomic |
| `061-fedora-flatpaks` | `run_once_` | fedora-atomic |
| `060-arch-paru` | `run_once_` | arch |
| `061-arch-packages` | `run_once_` | arch |
| `080-gnome-catppuccin` | `run_once_` | de=gnome |
| `081-gnome-extensions` | `run_once_` | de=gnome |
| `082-gnome-dconf` | `run_once_` | de=gnome |
| `080-hyprland-deps` | `run_once_` | de=hyprland |
| `080-kde-catppuccin` | `run_once_` | de=kde |
| `fedora-security` | `run_onchange_` | fedora-atomic |

### Script sources (migrated from `Temp/`)

| Temp/ script | Migrates to |
|---|---|
| `install-tailscale-quick.sh` | `run_once_060-fedora-tailscale.sh.tmpl` |
| `security-hardening.sh` | `run_onchange_fedora-security.sh.tmpl` |
| `setup-catppuccin-gnome49.sh` | `run_once_080-gnome-catppuccin.sh.tmpl` |
| `apply-gnome-shell-theme.sh` | `run_once_080-gnome-catppuccin.sh.tmpl` |
| `configure-tiling-shell.sh` | `run_once_081-gnome-extensions.sh.tmpl` |
| `configure-yazi.sh` | `run_once_030-install-cargo-tools.sh` |
| `setup-zsh-completions.sh` | `run_once_020-install-cli-tools.sh.tmpl` |
| `fix-ssh-hostkeys.sh` | standalone helper (not auto-run) |

---

## Day-to-Day Workflow

### Common commands

```bash
chezmoi cd                          # Open shell in source dir (~/.local/share/chezmoi)
chezmoi diff                        # Preview what would change
chezmoi apply                       # Apply source → $HOME
chezmoi update                      # git pull + apply (use on non-primary machines)
chezmoi edit ~/.config/zsh/aliases.zsh  # Edit tracked file
chezmoi add ~/.config/new-tool/config   # Start tracking a new file
chezmoi doctor                      # Diagnose issues
```

### Adding a new secret

1. Add key to `secrets.example.toml` (commit this)
2. Add key + value to `~/.config/chezmoi/chezmoi.toml` (never commit)
3. Reference in template: `{{ .newApiKey }}`
4. `chezmoi apply`

### Adding a new config file

```bash
# Plain file
chezmoi add ~/.config/tool/config

# Sensitive file (sets 600, adds private_ prefix)
chezmoi add --encrypt ~/.config/tool/secret-config

# Template (content varies per machine)
chezmoi add --template ~/.config/zsh/env.zsh
```

### Syncing across machines

```bash
# Primary machine — after changes
chezmoi cd && git add -A && git commit -m "feat: ..." && git push

# Other machines
chezmoi update
```

### Re-running a run_once_ script

```bash
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

---

## Consolidated Secrets File

At the end of implementation, a single `~/.config/chezmoi/chezmoi.toml` file is generated locally. This is the **only** file on the machine that holds real secret values. It is:

- Created by `chezmoi init` (interactive wizard)
- Stored at: **`~/.config/chezmoi/chezmoi.toml`**
- Permissions: `600` (owner read/write only)
- **Never committed** — chezmoi ignores it by default
- Backed up manually (e.g. to a password manager or encrypted drive)

Structure reference: see `secrets.example.toml` in the repo root.

---

## What Is NOT Tracked

| Path | Reason |
|---|---|
| `~/.config/gh/hosts.yml` | GitHub tokens |
| `~/.ssh/id_*` | Private keys |
| `~/.config/Antigravity/` | Electron app cache |
| `~/.config/LM-Studio/` | App data |
| `~/.config/github-copilot/versions.json` | Auto-generated |
| `~/.config/dconf/` | Binary — use dconf dump script instead |
| `~/.config/evolution/` | Mail client data |
| `~/.config/uv/uv-receipt.json` | Auto-generated |
| `~/.zsh_history` | Personal history |
| `~/.claude.json` (rendered) | Secret — rendered from template |
