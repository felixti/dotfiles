# AGENTS.md — LLM Operating Guide for felixti/dotfiles

## What This Repo Is

Chezmoi-managed dotfiles for reproducible multi-platform, multi-DE machine setup. One repo bootstraps a complete development environment across 4 distro flavors and 4 desktop environments.

## Architecture

**2D matrix:** `flavor` × `de`

| | gnome | kde | hyprland | none |
|---|---|---|---|---|
| **fedora-atomic** | Bluefin | Aurora | HyDE | headless/server |
| **arch** | Arch+GNOME | CachyOS KDE | CachyOS Hyprland | headless |
| **debian** | Ubuntu/Pop | Kubuntu | source-built | headless |
| **macos** | — | — | — | CLI-only |

**Template variables** (set once during `chezmoi init`, stored in `~/.config/chezmoi/chezmoi.toml`):
- `flavor` — `fedora-atomic` | `arch` | `debian` | `macos`
- `de` — `gnome` | `kde` | `hyprland` | `none`
- `fileManager` — `yazi` | `nemo`
- `gitName`, `gitEmail` — git identity
- `unsplashApiKey` — wallpaper-fetch (optional)

## Key Conventions

### File Naming (Chezmoi)

| Prefix | Meaning |
|--------|---------|
| `dot_` | Becomes `.filename` in `$HOME` |
| `private_dot_config/` | Becomes `~/.config/` with 0700 permissions |
| `symlink_` | Creates a symlink |
| `.tmpl` suffix | Go template — rendered using chezmoi data |
| `run_once_NNN-` | Script that runs once (ordered by NNN) |
| `run_onchange_` | Script that re-runs when its content changes |

### Script Numbering

```
000  — system update (runs first)
010  — homebrew
020  — CLI tools (brew)
030  — cargo tools
040  — language runtimes (nvm, rustup, bun, uv)
050  — AI agents (claude-code, codex, opencode)
060  — distro-specific (tailscale, paru, packages)
061  — flatpaks, arch packages
080  — DE-specific (gnome, kde, hyprland themes/extensions)
```

### Conditional Guards

Scripts use chezmoi template guards at line 2 to skip irrelevant platforms:
```bash
{{ if ne .flavor "fedora-atomic" }}exit 0{{ end }}
{{ if ne .de "gnome" }}exit 0{{ end }}
```

`.chezmoiignore` uses the same variables to exclude entire config directories:
```
{{ if ne .de "hyprland" }}
.config/hypr
.config/waybar
{{ end }}
```

### Shell Config Architecture

```
~/.zshrc  (dot_zshrc.tmpl)
  └── ~/.config/zsh/main.zsh
        ├── env.zsh        — $EDITOR, $PATH, Homebrew, runtimes
        ├── aliases.zsh    — modern tool aliases (eza, bat, fd, rg, zoxide)
        ├── functions.zsh  — yy(), fzf functions (fe, fif, fcd, fkill, fbr)
        ├── starship-themes.zsh — theme switcher (minimal/developer/cyber)
        ├── tmux-helpers.zsh    — tmux aliases, tswitch, auto-attach SSH
        └── tools.zsh      — starship/zoxide/fzf/thefuck init (MUST be last)
```

Bash has a separate minimal config (`dot_bashrc`) — it does NOT source the zsh modules.

### Secrets Strategy

- **Never committed:** `~/.config/chezmoi/chezmoi.toml` (real values)
- **Committed:** `secrets.example.toml` (structure reference, zero values)
- **AI tools** (Claude Code, Codex, Kimi) authenticate via OAuth — no API keys needed
- **Unsplash** is the only API key, optional, for wallpaper-fetch

### External Dependencies

Pinned in `.chezmoiexternal.toml`:
- **antidote** `v1.9.8` — zsh plugin manager
- **tpm** `v3.1.0` — tmux plugin manager

## How To Make Changes

### Adding a new CLI tool

1. Add to the `TOOLS` array in `.chezmoiscripts/run_once_020-install-cli-tools.sh.tmpl`
2. If it needs an alias, add to `private_dot_config/zsh/aliases.zsh`
3. If it needs shell init (`eval "$(tool init zsh)"`), add to `private_dot_config/zsh/tools.zsh.tmpl`
4. `chezmoi apply` to test

### Adding a new chezmoi template variable

1. Add prompt to `.chezmoi.toml.tmpl`:
   ```
   {{- $var := promptStringOnce . "varName" "Description" -}}
   ```
2. Add to `[data]` block: `varName = {{ $var | quote }}`
3. Add to `secrets.example.toml` with a comment
4. Reference in templates as `{{ .varName }}`

### Adding a new run_once script

1. Pick a number following the ordering convention (000–080)
2. Use `#!/usr/bin/env bash` shebang
3. Add `set -euo pipefail` (unless you need manual error handling)
4. Add chezmoi template guard if platform/DE-specific:
   ```bash
   {{ if ne .flavor "arch" }}exit 0{{ end }}
   ```
5. Name: `.chezmoiscripts/run_once_NNN-description.sh` (add `.tmpl` if it uses template syntax)

### Adding DE-specific config

1. Put configs under `private_dot_config/` using the chezmoi naming convention
2. Add exclusion guard to `.chezmoiignore`:
   ```
   {{ if ne .de "your-de" }}
   .config/your-config-dir
   {{ end }}
   ```

### Updating pinned versions

- **nvm:** Edit version in `.chezmoiscripts/run_once_040-install-runtimes.sh`
- **antidote/tpm:** Edit `tag` in `.chezmoiexternal.toml`
- **fail2ban:** Edit image tag in `.chezmoiscripts/run_onchange_fedora-security.sh.tmpl`

## Testing Changes

```bash
chezmoi diff          # Preview what would change
chezmoi apply -n      # Dry run (no changes)
chezmoi apply         # Apply changes
chezmoi doctor        # Diagnose issues
```

For scripts: they run via `chezmoi apply` automatically. To re-run a `run_once_` script, delete its state:
```bash
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

## Bootstrap Quick Reference

### Fedora Aurora (fedora-atomic + kde)
```bash
ujust update                                    # update base OS first
sh -c "$(curl -fsLS get.chezmoi.io)"           # install chezmoi
chezmoi init --apply gh:felixti/dotfiles       # select: fedora-atomic, kde, yazi
```
Manual step after: enable Krohnkite in System Settings → KWin Scripts.

### CachyOS Hyprland (arch + hyprland)
```bash
sudo pacman -Sy archlinux-keyring              # refresh keyring
sh -c "$(curl -fsLS get.chezmoi.io)"           # install chezmoi
chezmoi init --apply gh:felixti/dotfiles       # select: arch, hyprland, nemo
```
GPU auto-setup: `sudo chwd -a` (CachyOS detects AMD/NVIDIA automatically).

### macOS
```bash
sh -c "$(curl -fsLS get.chezmoi.io)"           # install chezmoi
chezmoi init --apply gh:felixti/dotfiles       # select: macos, none, yazi
```
Lightest path — no DE scripts, no flatpaks, no system update.

### After Bootstrap (all platforms)
```bash
update                                          # unified update: dotfiles + brew + OS + runtimes
```

## Troubleshooting

### Re-run failed setup scripts

`run_once_` scripts execute exactly once. If a script fails mid-bootstrap (network issue, etc.), chezmoi marks it as "done" and won't retry. To re-trigger:
```bash
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

### Script fails with "unbound variable"

All scripts use `set -euo pipefail`. If a variable is unset, the script exits. Fix: use `${VAR:-default}` for optional variables.

**Exception:** `run_once_080-gnome-catppuccin.sh.tmpl` intentionally does NOT use `set -e` — it handles errors manually with `|| true`.

### chezmoi apply skips expected files

Check `.chezmoiignore` — files are conditionally excluded based on `de` and `fileManager`. Verify your settings:
```bash
chezmoi data | grep -E "de|flavor|fileManager"
```

### Change bootstrap answers after init

Edit `~/.config/chezmoi/chezmoi.toml` directly, then `chezmoi apply`.

## File Map

| Path | Purpose |
|------|---------|
| `.chezmoi.toml.tmpl` | Bootstrap wizard — 6 prompts |
| `.chezmoiignore` | Conditional file exclusion (DE, fileManager) |
| `.chezmoiexternal.toml` | External git repos (antidote, tpm) |
| `secrets.example.toml` | Secret structure reference (never real values) |
| `.chezmoiscripts/` | 20 setup scripts (ordered 000–080) |
| `bin/update.sh.tmpl` | Unified update command |
| `dot_zshrc.tmpl` | Zsh entry point (antidote, modular sourcing) |
| `dot_bashrc` | Bash config (standalone, minimal) |
| `dot_bash_profile` | Bash login shell (sources bashrc) |
| `dot_gitconfig.tmpl` | Git config (name, email, credential helpers) |
| `dot_zsh_plugins.txt` | Antidote plugin list |
| `symlink_dot_tmux.conf` | Symlink to tmux config |
| `private_dot_config/zsh/` | 8 modular zsh configs + completions/ |
| `private_dot_config/nvim/` | AstroNvim v4 config |
| `private_dot_config/tmux/` | Tmux + Catppuccin theme |
| `private_dot_config/ghostty/` | Ghostty terminal config |
| `private_dot_config/kitty/` | Kitty terminal config |
| `private_dot_config/starship/` | 3 Starship prompt themes |
| `private_dot_config/yazi/` | Yazi file manager config |
| `private_dot_config/dconf/` | GNOME dconf settings dump |
| `private_dot_config/hypr/` | Hyprland modular config |
| `private_dot_config/waybar/` | Waybar status bar |
| `private_dot_config/wofi/` | Wofi app launcher |
| `private_dot_config/kde/` | KDE configs (kwinrc, kdeglobals) |
| `docs/PLATFORMS.md` | Platform-specific notes and GPU reference |

## Do NOT

- Commit real secrets to this repo — they belong in `~/.config/chezmoi/chezmoi.toml`
- Add `set -euo pipefail` to `run_once_080-gnome-catppuccin.sh.tmpl` — it uses manual `|| true` error handling intentionally
- Use `#!/bin/bash` — all scripts use `#!/usr/bin/env bash`
- Hardcode absolute paths with usernames — always use `$HOME`
- Add API key exports for Claude/Codex/Kimi — they use OAuth now
- Shadow POSIX commands in scripts — aliases like `find='fd'` are interactive-shell only
