# Dotfiles Audit Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix all 17 issues found in the dotfiles audit — hardcoded paths, DRY violations, missing template variables, script hardening, and quality improvements.

**Architecture:** Pure config/script changes in a chezmoi-managed dotfiles repo. No new files created. Changes are grouped into 7 tasks: critical path fixes, DRY consolidation, template gap fixes, API key removal, script hardening (shebangs + pipefail), external dependency pinning, and starship theme fix.

**Tech Stack:** Chezmoi templates (Go template syntax), Bash, Zsh, TOML

---

### Task 1: Fix hardcoded paths in bash configs

**Files:**
- Modify: `dot_bashrc:39,42`
- Modify: `dot_bash_profile:10-11`

- [ ] **Step 1: Fix cargo PATH in dot_bashrc**

In `dot_bashrc`, replace line 39:
```bash
# Old:
export PATH="/var/home/felix-powerhouse/.cargo/bin:$PATH"
# New:
export PATH="$HOME/.cargo/bin:$PATH"
```

- [ ] **Step 2: Fix LM Studio PATH in dot_bashrc**

In `dot_bashrc`, replace line 42:
```bash
# Old:
export PATH="$PATH:/var/home/felix-powerhouse/.lmstudio/bin"
# New:
export PATH="$PATH:$HOME/.lmstudio/bin"
```

- [ ] **Step 3: Remove duplicate LM Studio PATH from dot_bash_profile**

In `dot_bash_profile`, remove lines 10-11:
```bash
# Remove these two lines entirely:

# Added by LM Studio CLI tool (lms)
export PATH="$PATH:/var/home/felix-powerhouse/.lmstudio/bin"
```

The file should end after the bashrc sourcing block (line 7). `dot_bashrc` is sourced by `dot_bash_profile`, so the PATH is already set.

- [ ] **Step 4: Verify no hardcoded paths remain**

Run: `grep -r "felix-powerhouse" dot_bashrc dot_bash_profile`
Expected: No matches.

- [ ] **Step 5: Commit**

```bash
git add dot_bashrc dot_bash_profile
git commit -m "fix: replace hardcoded paths with \$HOME in bash configs"
```

---

### Task 2: Deduplicate yy() and fix alias collision

**Files:**
- Modify: `dot_zshrc.tmpl:59-67`
- Modify: `private_dot_config/zsh/tmux-helpers.zsh:48`

- [ ] **Step 1: Remove duplicate yy() from dot_zshrc.tmpl**

In `dot_zshrc.tmpl`, remove lines 59-67 (the `yy()` function and its comment). The block to remove:
```bash
# Yazi cd-on-quit
function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}
```

The canonical copy lives in `private_dot_config/zsh/functions.zsh:6-13` (uses `z` instead of `cd --` for zoxide integration). The `dot_bashrc` copy (lines 28-35) stays because bash doesn't source zsh config.

- [ ] **Step 2: Fix alias collision — rename tmux switcher alias**

In `private_dot_config/zsh/tmux-helpers.zsh`, replace line 48:
```bash
# Old:
alias ts='tswitch'
# New:
alias tsw='tswitch'
```

This resolves the collision with `aliases.zsh:56` where `ts='tailscale'`.

- [ ] **Step 3: Verify no duplicate yy() in zshrc**

Run: `grep -n "function yy\|^yy()" dot_zshrc.tmpl`
Expected: No matches.

- [ ] **Step 4: Commit**

```bash
git add dot_zshrc.tmpl private_dot_config/zsh/tmux-helpers.zsh
git commit -m "fix: deduplicate yy() function and resolve ts alias collision"
```

---

### Task 3: Wire missing template variables

**Files:**
- Modify: `.chezmoi.toml.tmpl:8-9`
- Modify: `.chezmoiignore` (add block after KDE section)

- [ ] **Step 1: Add unsplashApiKey prompt to .chezmoi.toml.tmpl**

In `.chezmoi.toml.tmpl`, add a new prompt line after the `kimiApiKey` line (line 8). Insert:
```
{{- $unsplash := promptStringOnce . "unsplashApiKey" "Unsplash API key (blank to skip)" -}}
```

And add to the `[data]` block (after `kimiApiKey`):
```
  unsplashApiKey  = {{ $unsplash | quote }}
```

The full file after this change (before API key removal in Task 4):
```
{{- $flavor    := promptStringOnce . "flavor"          "Distro flavor (fedora-atomic/arch/debian/macos)" -}}
{{- $de        := promptStringOnce . "de"              "Desktop env (gnome/kde/hyprland/none)" -}}
{{- $fileManager := promptStringOnce . "fileManager" "File manager (yazi/nemo)" -}}
{{- $name      := promptStringOnce . "gitName"         "Git full name" -}}
{{- $email     := promptStringOnce . "gitEmail"        "Git email" -}}
{{- $anthropic := promptStringOnce . "anthropicApiKey" "Anthropic API key (blank to skip)" -}}
{{- $openai    := promptStringOnce . "openaiApiKey"    "OpenAI API key (blank to skip)" -}}
{{- $kimi      := promptStringOnce . "kimiApiKey"      "Kimi API key (blank to skip)" -}}
{{- $unsplash  := promptStringOnce . "unsplashApiKey"  "Unsplash API key (blank to skip)" -}}

[data]
  flavor          = {{ $flavor    | quote }}
  de              = {{ $de        | quote }}
  fileManager     = {{ $fileManager | quote }}
  gitName         = {{ $name      | quote }}
  gitEmail        = {{ $email     | quote }}
  anthropicApiKey = {{ $anthropic | quote }}
  openaiApiKey    = {{ $openai    | quote }}
  kimiApiKey      = {{ $kimi      | quote }}
  unsplashApiKey  = {{ $unsplash  | quote }}
```

- [ ] **Step 2: Add fileManager conditional to .chezmoiignore**

In `.chezmoiignore`, add a new block after the KDE section (after line 32):
```
# File manager: Nemo configs (only when nemo is selected)
{{ if ne .fileManager "nemo" }}
.config/nemo
{{ end }}
```

- [ ] **Step 3: Commit**

```bash
git add .chezmoi.toml.tmpl .chezmoiignore
git commit -m "feat: wire unsplashApiKey and fileManager into chezmoi templates"
```

---

### Task 4: Remove API key infrastructure (OAuth migration)

**Files:**
- Modify: `.chezmoi.toml.tmpl`
- Modify: `private_dot_config/zsh/env.zsh.tmpl:39-49`
- Modify: `secrets.example.toml`

- [ ] **Step 1: Remove API key prompts from .chezmoi.toml.tmpl**

Remove the three API key prompt lines and their [data] entries. The file becomes:
```
{{- $flavor      := promptStringOnce . "flavor"          "Distro flavor (fedora-atomic/arch/debian/macos)" -}}
{{- $de          := promptStringOnce . "de"              "Desktop env (gnome/kde/hyprland/none)" -}}
{{- $fileManager := promptStringOnce . "fileManager"     "File manager (yazi/nemo)" -}}
{{- $name        := promptStringOnce . "gitName"         "Git full name" -}}
{{- $email       := promptStringOnce . "gitEmail"        "Git email" -}}
{{- $unsplash    := promptStringOnce . "unsplashApiKey"  "Unsplash API key (blank to skip)" -}}

[data]
  flavor         = {{ $flavor      | quote }}
  de             = {{ $de          | quote }}
  fileManager    = {{ $fileManager | quote }}
  gitName        = {{ $name        | quote }}
  gitEmail       = {{ $email       | quote }}
  unsplashApiKey = {{ $unsplash    | quote }}
```

- [ ] **Step 2: Remove API key exports from env.zsh.tmpl**

In `private_dot_config/zsh/env.zsh.tmpl`, remove the entire "API KEYS" section (lines 39-49):
```
# ============================================
# API KEYS (from chezmoi data — never hardcoded)
# ============================================
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

Remove all 12 lines above (the section header comment and all 3 conditional blocks).

- [ ] **Step 3: Update secrets.example.toml**

Replace the entire file content with:
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

- [ ] **Step 4: Verify no stale API key references remain in templates**

Run: `grep -rn "anthropicApiKey\|openaiApiKey\|kimiApiKey" .chezmoi.toml.tmpl private_dot_config/zsh/env.zsh.tmpl secrets.example.toml`
Expected: No matches.

- [ ] **Step 5: Commit**

```bash
git add .chezmoi.toml.tmpl private_dot_config/zsh/env.zsh.tmpl secrets.example.toml
git commit -m "feat: remove API key prompts — Claude/Codex/Kimi now use OAuth"
```

---

### Task 5: Harden all scripts (shebangs + pipefail + NVM guard + fail2ban pin)

**Files:**
- Modify: All 20 scripts in `.chezmoiscripts/`

**Important exception:** `run_once_080-gnome-catppuccin.sh.tmpl` intentionally has `# set -e` (commented out) because it uses manual error handling with `|| true` patterns throughout. Do NOT add `set -euo pipefail` to this script — only update its shebang.

- [ ] **Step 1: Standardize shebangs in all 20 scripts**

In every script in `.chezmoiscripts/`, replace:
```bash
#!/bin/bash
```
with:
```bash
#!/usr/bin/env bash
```

All 20 scripts:
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

- [ ] **Step 2: Upgrade set -e to set -euo pipefail in 19 scripts**

In every script EXCEPT `run_once_080-gnome-catppuccin.sh.tmpl`, replace:
```bash
set -e
```
with:
```bash
set -euo pipefail
```

Skip `run_once_080-gnome-catppuccin.sh.tmpl` — it intentionally has `# set -e` commented out because the script uses manual `|| true` error handling for gsettings/git commands that may fail on partial setups.

- [ ] **Step 3: Pin nvm to release tag**

In `run_once_040-install-runtimes.sh`, replace:
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh | bash
```
with:
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
```

- [ ] **Step 4: Add NVM guard to AI agents script**

In `run_once_050-install-ai-agents.sh`, replace lines 5-6:
```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
```
with:
```bash
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    source "$NVM_DIR/nvm.sh"
else
    echo "ERROR: nvm not found at $NVM_DIR — run install-runtimes first"
    exit 1
fi
```

- [ ] **Step 5: Pin fail2ban Docker image**

In `run_onchange_fedora-security.sh.tmpl`, replace:
```bash
        crazymax/fail2ban:latest 2>/dev/null; then
```
with:
```bash
        crazymax/fail2ban:1.1.0 2>/dev/null; then
```

- [ ] **Step 6: Verify all shebangs and pipefail**

Run: `grep -l '#!/bin/bash' .chezmoiscripts/`
Expected: No matches (all should be `#!/usr/bin/env bash`).

Run: `grep -rn '^set -e$' .chezmoiscripts/`
Expected: No matches (all should be `set -euo pipefail`, except gnome-catppuccin which has `# set -e`).

- [ ] **Step 7: Commit**

```bash
git add .chezmoiscripts/
git commit -m "fix: harden scripts — portable shebangs, pipefail, pin nvm/fail2ban"
```

---

### Task 6: Pin external dependencies

**Files:**
- Modify: `.chezmoiexternal.toml`

- [ ] **Step 1: Pin antidote and tpm to release tags**

Replace the entire `.chezmoiexternal.toml` with:
```toml
# External sources managed by chezmoi
# chezmoi fetches these on apply if they don't exist

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

- [ ] **Step 2: Verify chezmoi accepts the tag syntax**

Run: `chezmoi doctor` (if chezmoi is installed) or verify the TOML is valid:
Run: `python3 -c "import tomllib; tomllib.load(open('.chezmoiexternal.toml', 'rb')); print('valid')"`
Expected: `valid`

- [ ] **Step 3: Commit**

```bash
git add .chezmoiexternal.toml
git commit -m "fix: pin antidote and tpm to release tags"
```

---

### Task 7: Fix starship theme silent failure

**Files:**
- Modify: `private_dot_config/zsh/starship-themes.zsh:54-57`

- [ ] **Step 1: Replace silent fallback with existence check**

In `private_dot_config/zsh/starship-themes.zsh`, replace lines 54-57:
```bash
# Initialize with developer theme by default if no starship.toml exists
if [ ! -f "$HOME/.config/starship.toml" ]; then
    theme_developer 2>/dev/null || true
fi
```
with:
```bash
# Initialize with developer theme by default if no starship.toml exists
if [ ! -f "$HOME/.config/starship.toml" ]; then
    if [ -f "${STARSHIP_DIR}/developer.toml" ]; then
        theme_developer
    fi
fi
```

This makes it clear when the theme file is missing rather than silently doing nothing.

- [ ] **Step 2: Commit**

```bash
git add private_dot_config/zsh/starship-themes.zsh
git commit -m "fix: replace silent starship theme fallback with existence check"
```
