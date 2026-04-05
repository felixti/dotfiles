# Dotfiles Audit Fixes — Consolidate + Fix

**Date:** 2026-04-04
**Scope:** Full sweep of all issues found in dotfiles audit — 17 fixes, 5 intentionally skipped.
**Approach:** Surgical fixes with targeted consolidation of duplicated logic (Approach B).

---

## Section 1: Critical Fixes

### 1a. Replace hardcoded paths with `$HOME`

**Files:** `dot_bashrc`, `dot_bash_profile`

Replace every occurrence of `/var/home/felix-powerhouse/` with `$HOME/`:

- `dot_bashrc:39` — `export PATH="$HOME/.cargo/bin:$PATH"`
- `dot_bashrc:42` — `export PATH="$PATH:$HOME/.lmstudio/bin"`
- `dot_bash_profile:11` — remove entirely (duplicate of `dot_bashrc:42`, handled in 2b)

### 1b. Add `set -euo pipefail` and pin nvm

**File:** `.chezmoiscripts/run_once_040-install-runtimes.sh`

- Replace `set -e` with `set -euo pipefail`
- Change nvm install URL from `HEAD` to `v0.40.1`:
  ```bash
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  ```

### 1c. Add NVM guard with explicit error

**File:** `.chezmoiscripts/run_once_050-install-ai-agents.sh`

Replace the silent `&&` NVM source with an explicit guard:
```bash
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    source "$NVM_DIR/nvm.sh"
else
    echo "ERROR: nvm not found at $NVM_DIR — run install-runtimes first"
    exit 1
fi
```

---

## Section 2: Consolidation (DRY Fixes)

### 2a. Deduplicate `yy()` function

**Remove from:** `dot_zshrc.tmpl` (lines 59–67)
**Keep in:** `private_dot_config/zsh/functions.zsh` (lines 6–13, uses `z` for zoxide)
**Keep in:** `dot_bashrc` (lines 28–35, uses `cd --` for POSIX — correct for bash)

### 2b. Remove duplicate LM Studio PATH from `dot_bash_profile`

**File:** `dot_bash_profile`

Remove line 11 (`export PATH="$PATH:/var/home/felix-powerhouse/.lmstudio/bin"`). This is already set in `dot_bashrc:42` which is sourced by `dot_bash_profile`.

### 2c. Rename tmux switcher alias to avoid collision

**File:** `private_dot_config/zsh/tmux-helpers.zsh`

Change `alias ts='tswitch'` → `alias tsw='tswitch'` (line 48). Tailscale keeps `ts` in `aliases.zsh:56`.

---

## Section 3: Template & Config Gaps

### 3a. Wire `unsplashApiKey` into chezmoi prompts

**File:** `.chezmoi.toml.tmpl`

Add after the existing prompts:
```
{{- $unsplash := promptStringOnce . "unsplashApiKey" "Unsplash API key (blank to skip)" -}}
```

Add to `[data]` block:
```
unsplashApiKey  = {{ $unsplash | quote }}
```

### 3b. Wire `fileManager` conditional into `.chezmoiignore`

**File:** `.chezmoiignore`

Add a block to conditionally exclude nemo configs:
```
{{ if ne .fileManager "nemo" }}
.config/nemo
{{ end }}
```

### 3c. Remove API key prompts and exports (OAuth migration)

Claude Code, Codex, and Kimi now authenticate via subscription OAuth. Remove API key infrastructure:

**`.chezmoi.toml.tmpl`:** Remove `$anthropic`, `$openai`, `$kimi` prompt lines and their `[data]` entries.

**`private_dot_config/zsh/env.zsh.tmpl`:** Remove the entire API keys section (lines 40–49):
```
{{- if .anthropicApiKey }}
export ANTHROPIC_API_KEY="{{ .anthropicApiKey }}"
{{- end }}
{{- if .openaiApiKey }}
export OPENAI_API_KEY="{{ .openaiApiKey }}"
{{- end }}
{{- if .kimiApiKey }}
export KIMI_API_KEY="{{ .kimiApiKey }}"
{{- end }}
```

**`secrets.example.toml`:** Remove `anthropicApiKey`, `openaiApiKey`, `kimiApiKey` entries.

---

## Section 4: Script Hardening

### 4a. Upgrade `set -e` to `set -euo pipefail` in all scripts

**Files:** All 20 scripts in `.chezmoiscripts/`:
- `run_once_000-system-update.sh.tmpl`
- `run_once_010-install-homebrew.sh.tmpl`
- `run_once_020-install-cli-tools.sh.tmpl`
- `run_once_030-install-cargo-tools.sh`
- `run_once_040-install-runtimes.sh`
- `run_once_050-install-ai-agents.sh`
- `run_once_060-arch-paru.sh.tmpl`
- `run_once_060-fedora-tailscale.sh.tmpl`
- `run_once_061-arch-packages.sh.tmpl`
- `run_once_061-fedora-flatpaks.sh.tmpl`
- `run_once_080-gnome-catppuccin.sh.tmpl`
- `run_once_080-hyprland-deps.sh.tmpl`
- `run_once_080-hyprland-sddm.sh.tmpl`
- `run_once_080-kde-catppuccin.sh.tmpl`
- `run_once_080-kde-gpu.sh.tmpl`
- `run_once_080-kde-gtk-sync.sh.tmpl`
- `run_once_080-kde-kwin.sh.tmpl`
- `run_once_081-gnome-extensions.sh.tmpl`
- `run_once_082-gnome-dconf.sh.tmpl`
- `run_onchange_fedora-security.sh.tmpl`

### 4b. Pin nvm to release tag

**File:** `.chezmoiscripts/run_once_040-install-runtimes.sh`

Already covered in 1b — pin to `v0.40.1`.

### 4c. Standardize shebangs

**Files:** All 20 scripts listed in 4a.

Change `#!/bin/bash` → `#!/usr/bin/env bash` for portability across distros.

### 4d. Pin fail2ban Docker image

**File:** `.chezmoiscripts/run_onchange_fedora-security.sh.tmpl`

Change `crazymax/fail2ban:latest` → `crazymax/fail2ban:1.1.0`.

---

## Section 5: Low-Severity & Quality

### 5a. Starship theme silent failure

**File:** `private_dot_config/zsh/starship-themes.zsh`

Replace the silent fallback at line 55–57:
```bash
# Before
if [ ! -f "$HOME/.config/starship.toml" ]; then
    theme_developer 2>/dev/null || true
fi

# After
if [ ! -f "$HOME/.config/starship.toml" ]; then
    if [ -f "${STARSHIP_DIR}/developer.toml" ]; then
        theme_developer
    fi
fi
```

### 5b. Pin external dependencies to release tags

**File:** `.chezmoiexternal.toml`

```toml
[".antidote"]
    type = "git-repo"
    url = "https://github.com/mattmc3/antidote.git"
    refreshPeriod = "168h"
    tag = "v1.9.8"

[".tmux/plugins/tpm"]
    type = "git-repo"
    url = "https://github.com/tmux-plugins/tpm.git"
    refreshPeriod = "168h"
    tag = "v3.1.0"
```

### 5c. Update `secrets.example.toml`

Remove API keys, document remaining fields:
```toml
# Dotfiles secrets reference — structure only, zero values.
# Real values live ONLY in ~/.config/chezmoi/chezmoi.toml (never committed).
# chezmoi init will prompt for all these values interactively.

[data]
  flavor         = "fedora-atomic"   # fedora-atomic | arch | debian | macos
  de             = "gnome"           # gnome | kde | hyprland | none
  fileManager    = "yazi"            # yazi (TUI) | nemo (GUI, Catppuccin-styled)
  gitName        = ""                # e.g. "Felipe Felix"
  gitEmail       = ""                # e.g. "felixti@live.com"
  unsplashApiKey = ""                # wallpaper-fetch — UNSPLASH_API_KEY (free tier at unsplash.com/developers)
```

---

## Intentionally Skipped

| Issue | Reason |
|-------|--------|
| Shellcheck directives | No CI linting pipeline — directives would be noise |
| Tmux SSH auto-attach opt-out | Current behavior is correct for this use case |
| Health-check script | `chezmoi doctor` already exists |
| Rollback strategy docs | Overkill for personal dotfiles |
| `.gitignore` for `chezmoi.toml` | Already handled by chezmoi's design (lives outside source dir) |

---

## Files Changed (total: ~27)

| Category | Count | Files |
|----------|-------|-------|
| Shell configs | 3 | `dot_bashrc`, `dot_bash_profile`, `dot_zshrc.tmpl` |
| Zsh modules | 2 | `tmux-helpers.zsh`, `starship-themes.zsh` |
| Chezmoi config | 3 | `.chezmoi.toml.tmpl`, `.chezmoiignore`, `.chezmoiexternal.toml` |
| Templates | 1 | `env.zsh.tmpl` |
| Secrets example | 1 | `secrets.example.toml` |
| Scripts | 20 | All `.chezmoiscripts/run_once_*` and `run_onchange_*` |
