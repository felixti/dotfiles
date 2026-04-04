# Dotfiles Chezmoi Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a reproducible, multi-flavor dotfiles repository at `~/dotfiles` managed by chezmoi, covering Fedora Atomic, Arch/CachyOS, Debian, and macOS with GNOME, KDE, Hyprland, and headless DE support.

**Architecture:** Chezmoi source at `~/dotfiles` maps to `$HOME` using its naming conventions (`dot_`, `private_`, `.tmpl`). A 2D `flavor × de` parameter system (set once per machine in `~/.config/chezmoi/chezmoi.toml`) drives template rendering and `.chezmoiignore` exclusions. API key secrets are stored as env var exports in `env.zsh.tmpl`, populated from chezmoi data — never committed.

**Tech Stack:** chezmoi v2.70.0 (installed at `/home/linuxbrew/.linuxbrew/bin/chezmoi`), bash, Go templates, git

**Current machine:** Fedora Atomic (Bluefin), GNOME — `flavor=fedora-atomic`, `de=gnome`

---

## File Map

| Source path (in `~/dotfiles/`) | Target path (in `$HOME`) | Notes |
|---|---|---|
| `.chezmoi.toml.tmpl` | `~/.config/chezmoi/chezmoi.toml` | Generated on `chezmoi init`, never committed |
| `.chezmoiignore` | — | Excludes DE/flavor files |
| `.chezmoiexternal.toml` | — | External sources (antidote, tpm) |
| `secrets.example.toml` | — | Listed in `.chezmoiignore`, not applied |
| `dot_zshrc.tmpl` | `~/.zshrc` | Template: sources modular zsh |
| `dot_gitconfig.tmpl` | `~/.gitconfig` | Template: name/email from data |
| `dot_zprofile` | `~/.zprofile` | Plain copy |
| `dot_bash_profile` | `~/.bash_profile` | Plain copy |
| `dot_bashrc` | `~/.bashrc` | Plain copy |
| `dot_yarnrc` | `~/.yarnrc` | Plain copy |
| `dot_zsh_plugins.txt` | `~/.zsh_plugins.txt` | Plain copy |
| `symlink_dot_tmux.conf` | `~/.tmux.conf → ~/.config/tmux/tmux.conf` | Symlink recreation |
| `dot_config/zsh/main.zsh` | `~/.config/zsh/main.zsh` | Plain copy |
| `dot_config/zsh/aliases.zsh` | `~/.config/zsh/aliases.zsh` | Plain copy |
| `dot_config/zsh/env.zsh.tmpl` | `~/.config/zsh/env.zsh` | **Template**: flavor/OS-aware PATH |
| `dot_config/zsh/tools.zsh.tmpl` | `~/.config/zsh/tools.zsh` | **Template**: tool inits |
| `dot_config/zsh/functions.zsh` | `~/.config/zsh/functions.zsh` | Plain copy |
| `dot_config/zsh/tmux-helpers.zsh` | `~/.config/zsh/tmux-helpers.zsh` | Plain copy |
| `dot_config/zsh/starship-themes.zsh` | `~/.config/zsh/starship-themes.zsh` | Plain copy |
| `dot_config/zsh/completions/` | `~/.config/zsh/completions/` | Plain copy (all `_*` files) |
| `dot_config/tmux/` | `~/.config/tmux/` | All files + scripts/ |
| `dot_config/nvim/` | `~/.config/nvim/` | Full AstroNvim config |
| `dot_config/starship.toml` | `~/.config/starship.toml` | Active theme |
| `dot_config/starship/` | `~/.config/starship/` | Theme variants |
| `dot_config/ghostty/` | `~/.config/ghostty/` | Cross-platform terminal |
| `dot_config/kitty/kitty.conf` | `~/.config/kitty/kitty.conf` | Cross-platform terminal |
| `dot_config/yazi/` | `~/.config/yazi/` | All yazi files |
| `dot_config/television/config.toml` | `~/.config/television/config.toml` | |
| `dot_config/btop/btop.conf` | `~/.config/btop/btop.conf` | |
| `dot_config/glow/glow.yml` | `~/.config/glow/glow.yml` | |
| `dot_config/thefuck/settings.py` | `~/.config/thefuck/settings.py` | |
| `dot_config/gh/config.yml` | `~/.config/gh/config.yml` | NOT hosts.yml |
| `dot_config/pop-shell/config.json` | `~/.config/pop-shell/config.json` | GNOME only |
| `dot_config/gtk-3.0/settings.ini` | `~/.config/gtk-3.0/settings.ini` | GNOME only |
| `dot_config/gtk-4.0/settings.ini` | `~/.config/gtk-4.0/settings.ini` | GNOME only |
| `dot_config/hypr/hyprland.conf` | `~/.config/hypr/hyprland.conf` | Hyprland only |
| `dot_config/opencode/opencode.json` | `~/.config/opencode/opencode.json` | |
| `dot_codex/config.toml.tmpl` | `~/.codex/config.toml` | **Template**: strips machine-specific trust entries |
| `dot_kimi/config.toml` | `~/.kimi/config.toml` | Plain copy |
| `.chezmoiscripts/run_once_010-*` | — | Homebrew install |
| `.chezmoiscripts/run_once_020-*` | — | CLI tools |
| `.chezmoiscripts/run_once_030-*` | — | Cargo tools |
| `.chezmoiscripts/run_once_040-*` | — | Runtimes (nvm, bun, rustup, uv) |
| `.chezmoiscripts/run_once_050-*` | — | AI agents (claude, codex, opencode) |
| `.chezmoiscripts/run_once_060-fedora-*` | — | Fedora Atomic: tailscale, flatpaks |
| `.chezmoiscripts/run_onchange_fedora-security*` | — | Fedora: re-run on change |
| `.chezmoiscripts/run_once_060-arch-*` | — | Arch: paru + packages |
| `.chezmoiscripts/run_once_080-gnome-*` | — | GNOME: catppuccin, extensions, dconf |
| `.chezmoiscripts/run_once_080-hyprland-*` | — | Hyprland deps |
| `.chezmoiscripts/run_once_080-kde-*` | — | KDE catppuccin |

---

## Task 1: Configure chezmoi to use `~/dotfiles` as source

**Files:**
- Create: `~/.config/chezmoi/chezmoi.toml` (local only — never committed)

- [ ] **Step 1: Create chezmoi config dir and point it to ~/dotfiles**

```bash
mkdir -p ~/.config/chezmoi
cat > ~/.config/chezmoi/chezmoi.toml << 'EOF'
sourceDir = "/var/home/felix-powerhouse/dotfiles"
EOF
```

- [ ] **Step 2: Verify chezmoi sees the source dir**

```bash
chezmoi doctor
```

Expected: no errors, line showing `sourceDir = /var/home/felix-powerhouse/dotfiles`

- [ ] **Step 3: Verify chezmoi source dir**

```bash
chezmoi source-path
```

Expected output: `/var/home/felix-powerhouse/dotfiles`

---

## Task 2: Repo scaffolding — .gitignore + secrets.example.toml

**Files:**
- Create: `~/dotfiles/.gitignore`
- Create: `~/dotfiles/secrets.example.toml`

- [ ] **Step 1: Create .gitignore**

```bash
cat > /var/home/felix-powerhouse/dotfiles/.gitignore << 'EOF'
# OS
.DS_Store
*.swp
*.swo
*~

# Chezmoi external downloaded files
.chezmoiexternal.toml.cache

# Never commit these
*.secret
.env
EOF
```

- [ ] **Step 2: Create secrets.example.toml**

```bash
cat > /var/home/felix-powerhouse/dotfiles/secrets.example.toml << 'EOF'
# Dotfiles secrets reference — structure only, zero values.
# Real values live ONLY in ~/.config/chezmoi/chezmoi.toml (never committed).
# chezmoi init will prompt for all these values interactively.

[data]
  flavor          = "fedora-atomic"   # fedora-atomic | arch | debian | macos
  de              = "gnome"           # gnome | kde | hyprland | none
  gitName         = ""                # e.g. "Felipe Felix"
  gitEmail        = ""                # e.g. "felixti@live.com"
  anthropicApiKey = ""                # Claude Code — ANTHROPIC_API_KEY
  openaiApiKey    = ""                # Codex / OpenCode — OPENAI_API_KEY
  kimiApiKey      = ""                # Kimi Code — KIMI_API_KEY
EOF
```

- [ ] **Step 3: Commit**

```bash
cd /var/home/felix-powerhouse/dotfiles
git add .gitignore secrets.example.toml
git commit -m "chore: add .gitignore and secrets.example.toml"
```

---

## Task 3: Bootstrap wizard — `.chezmoi.toml.tmpl` + `.chezmoiignore`

**Files:**
- Create: `~/dotfiles/.chezmoi.toml.tmpl`
- Create: `~/dotfiles/.chezmoiignore`

- [ ] **Step 1: Create .chezmoi.toml.tmpl**

```bash
cat > /var/home/felix-powerhouse/dotfiles/.chezmoi.toml.tmpl << 'TMPL'
{{- $flavor    := promptStringOnce . "flavor"          "Distro flavor (fedora-atomic/arch/debian/macos)" -}}
{{- $de        := promptStringOnce . "de"              "Desktop env (gnome/kde/hyprland/none)" -}}
{{- $name      := promptStringOnce . "gitName"         "Git full name" -}}
{{- $email     := promptStringOnce . "gitEmail"        "Git email" -}}
{{- $anthropic := promptStringOnce . "anthropicApiKey" "Anthropic API key (blank to skip)" -}}
{{- $openai    := promptStringOnce . "openaiApiKey"    "OpenAI API key (blank to skip)" -}}
{{- $kimi      := promptStringOnce . "kimiApiKey"      "Kimi API key (blank to skip)" -}}

[data]
  flavor          = {{ $flavor    | quote }}
  de              = {{ $de        | quote }}
  gitName         = {{ $name      | quote }}
  gitEmail        = {{ $email     | quote }}
  anthropicApiKey = {{ $anthropic | quote }}
  openaiApiKey    = {{ $openai    | quote }}
  kimiApiKey      = {{ $kimi      | quote }}
TMPL
```

- [ ] **Step 2: Create .chezmoiignore**

```bash
cat > /var/home/felix-powerhouse/dotfiles/.chezmoiignore << 'EOF'
# Meta files — not applied to $HOME
# (chezmoi matches TARGET paths, i.e. relative to $HOME, not source paths)
docs
secrets.example.toml
README.md

# DE: GNOME-specific configs
{{ if ne .de "gnome" }}
.config/pop-shell
.config/gtk-3.0
.config/gtk-4.0
.config/org.gnome.Ptyxis
{{ end }}

# DE: Hyprland-specific configs
{{ if ne .de "hyprland" }}
.config/hypr
.config/waybar
.config/rofi
.config/dunst
.config/hyprlock
{{ end }}

# DE: KDE-specific configs
{{ if ne .de "kde" }}
.config/kdeglobals
.config/kwinrc
{{ end }}
EOF
```

- [ ] **Step 3: Verify template renders without error**

```bash
cd /var/home/felix-powerhouse/dotfiles
chezmoi execute-template < .chezmoi.toml.tmpl 2>&1 | head -5
```

Expected: outputs TOML with the current values (from `~/.config/chezmoi/chezmoi.toml`)

- [ ] **Step 4: Commit**

```bash
cd /var/home/felix-powerhouse/dotfiles
git add .chezmoi.toml.tmpl .chezmoiignore
git commit -m "feat: add chezmoi bootstrap wizard and ignore rules"
```

---

## Task 4: Migrate zsh configs

Copies all `~/.config/zsh/` files into source, then replaces `env.zsh` and `tools.zsh` with template versions.

**Files:**
- Create: `~/dotfiles/dot_config/zsh/` (all files)
- Create: `~/dotfiles/dot_config/zsh/env.zsh.tmpl` (replaces plain env.zsh)
- Create: `~/dotfiles/dot_config/zsh/tools.zsh.tmpl` (replaces plain tools.zsh)

- [ ] **Step 1: Add all zsh config files to chezmoi source**

```bash
chezmoi add ~/.config/zsh/main.zsh
chezmoi add ~/.config/zsh/aliases.zsh
chezmoi add ~/.config/zsh/functions.zsh
chezmoi add ~/.config/zsh/tmux-helpers.zsh
chezmoi add ~/.config/zsh/starship-themes.zsh
chezmoi add --recursive ~/.config/zsh/completions/
```

- [ ] **Step 2: Verify files landed in source**

```bash
ls /var/home/felix-powerhouse/dotfiles/dot_config/zsh/
```

Expected: `aliases.zsh  completions  functions.zsh  main.zsh  starship-themes.zsh  tmux-helpers.zsh`

- [ ] **Step 3: Write env.zsh.tmpl (flavor/OS-aware PATH)**

```bash
cat > /var/home/felix-powerhouse/dotfiles/dot_config/zsh/env.zsh.tmpl << 'TMPL'
# ============================================
# ENVIRONMENT VARIABLES
# ============================================

# Default applications
export EDITOR='nvim'
export VISUAL='code'
export PAGER='bat'
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Homebrew (prefix differs macOS vs Linux)
{{- if eq .chezmoi.os "darwin" }}
eval "$(/opt/homebrew/bin/brew shellenv)"
{{- else }}
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
{{- end }}

# .NET (fedora-atomic ships it natively)
{{- if eq .flavor "fedora-atomic" }}
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH"
{{- end }}

# Runtimes (guarded by existence — work on all flavors)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.bun/bin:$PATH"
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# LM Studio (Linux only)
{{- if ne .chezmoi.os "darwin" }}
export PATH="$PATH:$HOME/.lmstudio/bin"
{{- end }}

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

# ============================================
# TOOL CONFIGURATIONS
# ============================================

# fzf defaults
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --preview "bat --color=always --style=numbers --line-range=:500 {}" --bind "ctrl-u:half-page-up,ctrl-d:half-page-down,ctrl-h:preview-up,ctrl-l:preview-down"'
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
TMPL
```

- [ ] **Step 4: Write tools.zsh.tmpl (tool initializations)**

```bash
cat > /var/home/felix-powerhouse/dotfiles/dot_config/zsh/tools.zsh.tmpl << 'TMPL'
# ============================================
# TOOL INITIALIZATIONS
# ============================================

# Starship prompt (must be last for prompt customization)
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# zoxide (smart cd)
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi

# fzf
if command -v fzf &>/dev/null; then
    eval "$(fzf --zsh)"
fi

# thefuck
if command -v thefuck &>/dev/null; then
    eval "$(thefuck --alias)"
fi

# television shell integration
if command -v tv &>/dev/null; then
    eval "$(tv init zsh)"
fi

# ============================================
# AUTO-START SERVICES
# ============================================

# Tailscale (Linux only — macOS uses launchd)
{{- if ne .chezmoi.os "darwin" }}
if command -v tailscaled &>/dev/null; then
    pgrep -x tailscaled >/dev/null || sudo systemctl start tailscaled 2>/dev/null || true
fi
{{- end }}

# ============================================
# SSH AGENT (headless / server machines)
# ============================================
{{- if eq .de "none" }}
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null
fi
{{- end }}
TMPL
```

- [ ] **Step 5: Verify chezmoi sees these as managed**

```bash
chezmoi managed | grep zsh
```

Expected: lists `dot_config/zsh/aliases.zsh`, `dot_config/zsh/main.zsh`, etc.

- [ ] **Step 6: Commit**

```bash
cd /var/home/felix-powerhouse/dotfiles
git add dot_config/zsh/
git commit -m "feat: migrate zsh modular config with env/tools templates"
```

---

## Task 5: Migrate home root dotfiles

**Files:**
- Create: `dot_zshrc.tmpl`, `dot_gitconfig.tmpl`, `dot_zprofile`, `dot_bash_profile`, `dot_bashrc`, `dot_yarnrc`, `dot_zsh_plugins.txt`, `symlink_dot_tmux.conf`

- [ ] **Step 1: Add plain home root dotfiles**

```bash
chezmoi add ~/.zprofile
chezmoi add ~/.bash_profile
chezmoi add ~/.bashrc
chezmoi add ~/.yarnrc
chezmoi add ~/.zsh_plugins.txt
```

- [ ] **Step 2: Write dot_zshrc.tmpl**

Chezmoi does NOT know about `~/.zshrc` yet (we write the template manually):

```bash
cat > /var/home/felix-powerhouse/dotfiles/dot_zshrc.tmpl << 'TMPL'
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH"

# ============================================
# ZSH CORE OPTIONS
# ============================================
autoload -U compinit
setopt COMPLETE_IN_WORD
setopt AUTO_CD
setopt EXTENDED_GLOB
setopt NO_BEEP
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_VERIFY

HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=10000

# ============================================
# COMPLETION (cached, one rebuild per day)
# ============================================
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.m+1) ]]; then
    compinit -C
else
    compinit
fi

# ============================================
# ANTIDOTE PLUGIN MANAGER
# ============================================
zsh_plugins=${ZDOTDIR:-~}/.zsh_plugins.zsh
fpath+=(${ZDOTDIR:-~}/.antidote)
autoload -Uz $fpath[-1]/antidote
if [[ ! $zsh_plugins -nt ${zsh_plugins:r}.txt ]]; then
    (antidote bundle <${zsh_plugins:r}.txt >|$zsh_plugins)
fi
source $zsh_plugins

ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#663399,bold"

# ============================================
# MODULAR ZSH CONFIG
# ============================================
source ~/.config/zsh/main.zsh

# ============================================
# UBLUE BLING (Fedora Atomic only)
# ============================================
{{- if eq .flavor "fedora-atomic" }}
test -f /usr/share/ublue-os/bling/bling.sh && source /usr/share/ublue-os/bling/bling.sh
{{- end }}

# Yazi cd-on-quit
function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# Custom completions
fpath=(/var/home/felix-powerhouse/.config/zsh/completions $fpath)

[ -f ~/.zshrc.local ] && source ~/.zshrc.local
TMPL
```

- [ ] **Step 3: Write dot_gitconfig.tmpl**

```bash
cat > /var/home/felix-powerhouse/dotfiles/dot_gitconfig.tmpl << 'TMPL'
[user]
	name  = {{ .gitName }}
	email = {{ .gitEmail }}

[credential "https://github.com"]
	helper =
{{- if eq .chezmoi.os "darwin" }}
	helper = !/opt/homebrew/bin/gh auth git-credential
{{- else }}
	helper = !/home/linuxbrew/.linuxbrew/bin/gh auth git-credential
{{- end }}

[credential "https://gist.github.com"]
	helper =
{{- if eq .chezmoi.os "darwin" }}
	helper = !/opt/homebrew/bin/gh auth git-credential
{{- else }}
	helper = !/home/linuxbrew/.linuxbrew/bin/gh auth git-credential
{{- end }}

[core]
	editor = nvim

[init]
	defaultBranch = main

[pull]
	rebase = false
TMPL
```

- [ ] **Step 4: Create symlink for ~/.tmux.conf**

In chezmoi, a `symlink_` file's content is the link target (relative to `$HOME`):

```bash
printf '.config/tmux/tmux.conf' > /var/home/felix-powerhouse/dotfiles/symlink_dot_tmux.conf
```

This recreates `~/.tmux.conf -> ~/.config/tmux/tmux.conf` on every new machine.

- [ ] **Step 5: Verify diff looks right**

```bash
chezmoi diff
```

Expected: shows changes for `.zshrc`, `.gitconfig` (template-rendered), `.zprofile`, `.bash_profile`, `.bashrc`, `.yarnrc`, `.zsh_plugins.txt`

- [ ] **Step 6: Commit**

```bash
cd /var/home/felix-powerhouse/dotfiles
git add dot_zshrc.tmpl dot_gitconfig.tmpl dot_zprofile dot_bash_profile dot_bashrc dot_yarnrc dot_zsh_plugins.txt symlink_dot_tmux.conf
git commit -m "feat: migrate home root dotfiles"
```

---

## Task 6: Migrate tmux config

**Files:**
- Create: `dot_config/tmux/` (tmux.conf, keybindings.conf, plugins.conf, settings.conf, scripts/)

- [ ] **Step 1: Add all tmux config files**

```bash
chezmoi add ~/.config/tmux/tmux.conf
chezmoi add ~/.config/tmux/keybindings.conf
chezmoi add ~/.config/tmux/plugins.conf
chezmoi add ~/.config/tmux/settings.conf
chezmoi add --recursive ~/.config/tmux/scripts/
```

- [ ] **Step 2: Verify**

```bash
ls /var/home/felix-powerhouse/dotfiles/dot_config/tmux/
```

Expected: `keybindings.conf  plugins.conf  scripts  settings.conf  tmux.conf`

- [ ] **Step 3: Commit**

```bash
cd /var/home/felix-powerhouse/dotfiles
git add dot_config/tmux/
git commit -m "feat: migrate tmux config with status scripts"
```

---

## Task 7: Migrate Neovim config

**Files:**
- Create: `dot_config/nvim/` (full AstroNvim tree)

- [ ] **Step 1: Add nvim config recursively**

```bash
chezmoi add --recursive ~/.config/nvim/
```

Note: this includes `init.lua`, `lazy-lock.json` (intentionally pinned), `lua/`, `selene.toml`, `neovim.yml`. It skips `node_modules/` (not present in config dir).

- [ ] **Step 2: Verify key files exist in source**

```bash
ls /var/home/felix-powerhouse/dotfiles/dot_config/nvim/
ls /var/home/felix-powerhouse/dotfiles/dot_config/nvim/lua/plugins/
```

Expected first: `init.lua  lazy-lock.json  lua  neovim.yml  package-lock.json  package.json  README.md  selene.toml`
Expected second: `astrocore.lua  astrolsp.lua  astroui.lua  gh-copilot.lua  gitsigns.lua  mason.lua  neo-tree.lua  opencode.lua  treesitter.lua  undotree.lua  user.lua` (and others)

- [ ] **Step 3: Commit**

```bash
cd /var/home/felix-powerhouse/dotfiles
git add dot_config/nvim/
git commit -m "feat: migrate AstroNvim config with pinned lazy-lock.json"
```

---

## Task 8: Migrate terminal configs (ghostty + kitty)

**Files:**
- Create: `dot_config/ghostty/` (config, config.ghostty, themes/)
- Create: `dot_config/kitty/kitty.conf`

- [ ] **Step 1: Add ghostty config**

```bash
chezmoi add --recursive ~/.config/ghostty/
```

- [ ] **Step 2: Add kitty config**

```bash
chezmoi add ~/.config/kitty/kitty.conf
```

- [ ] **Step 3: Verify**

```bash
ls /var/home/felix-powerhouse/dotfiles/dot_config/ghostty/
ls /var/home/felix-powerhouse/dotfiles/dot_config/kitty/
```

Expected ghostty: `config  config.ghostty  themes`
Expected kitty: `kitty.conf`

- [ ] **Step 4: Commit**

```bash
cd /var/home/felix-powerhouse/dotfiles
git add dot_config/ghostty/ dot_config/kitty/
git commit -m "feat: migrate ghostty and kitty terminal configs"
```

---

## Task 9: Migrate starship config

**Files:**
- Create: `dot_config/starship/` (cyber.toml, developer.toml, minimal.toml)
- Create: `dot_config/starship.toml`

- [ ] **Step 1: Add starship themes directory and active config**

```bash
chezmoi add --recursive ~/.config/starship/
chezmoi add ~/.config/starship.toml
```

- [ ] **Step 2: Verify**

```bash
ls /var/home/felix-powerhouse/dotfiles/dot_config/starship/
ls /var/home/felix-powerhouse/dotfiles/dot_config/starship.toml
```

Expected starship dir: `cyber.toml  developer.toml  minimal.toml`

- [ ] **Step 3: Commit**

```bash
cd /var/home/felix-powerhouse/dotfiles
git add dot_config/starship/ dot_config/starship.toml
git commit -m "feat: migrate starship prompt config and themes"
```

---

## Task 10: Migrate CLI tool configs

Migrates: yazi, television, btop, glow, thefuck, gh (config.yml only).

**Files:**
- Create: `dot_config/yazi/` (yazi.toml, keymap.toml, init.lua, theme.toml — skip backup/ and flavors/)
- Create: `dot_config/television/config.toml`
- Create: `dot_config/btop/btop.conf`
- Create: `dot_config/glow/glow.yml`
- Create: `dot_config/thefuck/settings.py`
- Create: `dot_config/gh/config.yml`

- [ ] **Step 1: Add yazi core config files (skip backup and auto-downloaded flavors)**

```bash
chezmoi add ~/.config/yazi/yazi.toml
chezmoi add ~/.config/yazi/keymap.toml
chezmoi add ~/.config/yazi/init.lua
chezmoi add ~/.config/yazi/theme.toml
```

- [ ] **Step 2: Add remaining CLI tool configs**

```bash
chezmoi add ~/.config/television/config.toml
chezmoi add ~/.config/btop/btop.conf
chezmoi add ~/.config/glow/glow.yml
chezmoi add ~/.config/thefuck/settings.py
chezmoi add ~/.config/gh/config.yml
```

Note: do NOT add `~/.config/gh/hosts.yml` — it contains GitHub auth tokens.

- [ ] **Step 3: Verify gh only has config.yml**

```bash
ls /var/home/felix-powerhouse/dotfiles/dot_config/gh/
```

Expected: `config.yml` only (no hosts.yml)

- [ ] **Step 4: Commit**

```bash
cd /var/home/felix-powerhouse/dotfiles
git add dot_config/yazi/ dot_config/television/ dot_config/btop/ dot_config/glow/ dot_config/thefuck/ dot_config/gh/
git commit -m "feat: migrate CLI tool configs (yazi, television, btop, glow, thefuck, gh)"
```

---

## Task 11: GNOME-specific configs + dconf export

**Files:**
- Create: `dot_config/pop-shell/config.json`
- Create: `dot_config/gtk-3.0/settings.ini`
- Create: `dot_config/gtk-4.0/settings.ini`
- Create: `.chezmoiscripts/run_once_082-gnome-dconf.sh.tmpl`
- Create: `dot_config/dconf/settings.ini` (dconf dump — for the script to load)

- [ ] **Step 1: Add GNOME extension and GTK configs**

```bash
chezmoi add ~/.config/pop-shell/config.json
chezmoi add ~/.config/gtk-3.0/settings.ini
chezmoi add ~/.config/gtk-4.0/settings.ini
```

- [ ] **Step 2: Export current dconf settings**

```bash
mkdir -p /var/home/felix-powerhouse/dotfiles/dot_config/dconf
dconf dump / > /var/home/felix-powerhouse/dotfiles/dot_config/dconf/settings.ini
```

- [ ] **Step 3: Verify dconf dump has content**

```bash
wc -l /var/home/felix-powerhouse/dotfiles/dot_config/dconf/settings.ini
head -20 /var/home/felix-powerhouse/dotfiles/dot_config/dconf/settings.ini
```

Expected: several hundred lines, starting with GNOME section headers like `[org/gnome/desktop/...]`

- [ ] **Step 4: Add the dconf settings file to chezmoi**

```bash
chezmoi add /var/home/felix-powerhouse/dotfiles/dot_config/dconf/settings.ini 2>/dev/null || true
# File is already in the source dir — just ensure it's tracked by git
```

- [ ] **Step 5: Commit**

```bash
cd /var/home/felix-powerhouse/dotfiles
git add dot_config/pop-shell/ dot_config/gtk-3.0/ dot_config/gtk-4.0/ dot_config/dconf/
git commit -m "feat: migrate GNOME configs and dconf export"
```

---

## Task 12: Hyprland configs (from dotfiles_old)

**Files:**
- Create: `dot_config/hypr/hyprland.conf`

- [ ] **Step 1: Create hypr directory in source**

```bash
mkdir -p /var/home/felix-powerhouse/dotfiles/dot_config/hypr
```

- [ ] **Step 2: Copy hyprland.conf from dotfiles_old**

```bash
cp /var/home/felix-powerhouse/Temp/dotfiles_old/hyprland.conf \
   /var/home/felix-powerhouse/dotfiles/dot_config/hypr/hyprland.conf
```

- [ ] **Step 3: Verify file exists in source**

```bash
head -10 /var/home/felix-powerhouse/dotfiles/dot_config/hypr/hyprland.conf
```

Expected: shows Hyprland config header with monitor and autostart settings.

- [ ] **Step 4: Commit**

```bash
cd /var/home/felix-powerhouse/dotfiles
git add dot_config/hypr/
git commit -m "feat: add Hyprland config from dotfiles_old"
```

---

## Task 13: `.chezmoiexternal.toml` — pin external sources

Chezmoi can auto-fetch external tools (antidote, tpm) rather than requiring `run_once_` scripts for them.

**Files:**
- Create: `~/dotfiles/.chezmoiexternal.toml`

- [ ] **Step 1: Write .chezmoiexternal.toml**

```bash
cat > /var/home/felix-powerhouse/dotfiles/.chezmoiexternal.toml << 'EOF'
# External sources managed by chezmoi
# chezmoi fetches these on apply if they don't exist

[".antidote"]
    type = "git-repo"
    url = "https://github.com/mattmc3/antidote.git"
    refreshPeriod = "168h"

[".tmux/plugins/tpm"]
    type = "git-repo"
    url = "https://github.com/tmux-plugins/tpm.git"
    refreshPeriod = "168h"
EOF
```

- [ ] **Step 2: Verify chezmoi accepts the file**

```bash
chezmoi doctor 2>&1 | grep -i external || echo "no external errors"
```

- [ ] **Step 3: Commit**

```bash
cd /var/home/felix-powerhouse/dotfiles
git add .chezmoiexternal.toml
git commit -m "feat: add external sources for antidote and tpm"
```

---

## Task 14: Common bootstrap scripts (010–050)

**Files:**
- Create: `.chezmoiscripts/run_once_010-install-homebrew.sh.tmpl`
- Create: `.chezmoiscripts/run_once_020-install-cli-tools.sh.tmpl`
- Create: `.chezmoiscripts/run_once_030-install-cargo-tools.sh`
- Create: `.chezmoiscripts/run_once_040-install-runtimes.sh`
- Create: `.chezmoiscripts/run_once_050-install-ai-agents.sh`

- [ ] **Step 1: Create .chezmoiscripts directory**

```bash
mkdir -p /var/home/felix-powerhouse/dotfiles/.chezmoiscripts
```

- [ ] **Step 2: Write 010-install-homebrew.sh.tmpl**

```bash
cat > /var/home/felix-powerhouse/dotfiles/.chezmoiscripts/run_once_010-install-homebrew.sh.tmpl << 'TMPL'
#!/bin/bash
# Install Homebrew if not present
set -e
command -v brew &>/dev/null && exit 0

echo "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

{{- if eq .chezmoi.os "darwin" }}
eval "$(/opt/homebrew/bin/brew shellenv)"
{{- else }}
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
{{- end }}

echo "✓ Homebrew installed"
TMPL
```

- [ ] **Step 3: Write 020-install-cli-tools.sh.tmpl**

```bash
cat > /var/home/felix-powerhouse/dotfiles/.chezmoiscripts/run_once_020-install-cli-tools.sh.tmpl << 'TMPL'
#!/bin/bash
# Install cross-platform CLI tools via Homebrew
set -e

{{- if eq .chezmoi.os "darwin" }}
eval "$(/opt/homebrew/bin/brew shellenv)"
{{- else }}
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
{{- end }}

TOOLS=(
    eza       # modern ls
    bat       # modern cat
    fd        # modern find
    fzf       # fuzzy finder
    ripgrep   # modern grep
    zoxide    # smart cd
    starship  # prompt
    lazygit   # git TUI
    glow      # markdown reader
    television # fuzzy TUI (tv)
    thefuck   # typo corrector
    gh        # GitHub CLI
    btop      # resource monitor
    tmux      # terminal multiplexer
    neovim    # editor
)

for tool in "${TOOLS[@]}"; do
    brew list "$tool" &>/dev/null && continue
    echo "Installing $tool..."
    brew install "$tool"
done

echo "✓ CLI tools installed"
TMPL
```

- [ ] **Step 4: Write 030-install-cargo-tools.sh**

```bash
cat > /var/home/felix-powerhouse/dotfiles/.chezmoiscripts/run_once_030-install-cargo-tools.sh << 'EOF'
#!/bin/bash
# Install Rust-based tools via cargo
set -e
command -v cargo &>/dev/null || { echo "cargo not found, skipping"; exit 0; }

# yazi file manager (latest via cargo)
if ! command -v yazi &>/dev/null; then
    echo "Installing yazi..."
    cargo install --locked yazi-fm yazi-cli
    echo "✓ yazi installed"
fi
EOF
chmod +x /var/home/felix-powerhouse/dotfiles/.chezmoiscripts/run_once_030-install-cargo-tools.sh
```

- [ ] **Step 5: Write 040-install-runtimes.sh**

```bash
cat > /var/home/felix-powerhouse/dotfiles/.chezmoiscripts/run_once_040-install-runtimes.sh << 'EOF'
#!/bin/bash
# Install language runtime managers
set -e

# nvm (Node Version Manager)
if [ ! -d "$HOME/.nvm" ]; then
    echo "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh | bash
    echo "✓ nvm installed"
fi

# rustup (Rust)
if ! command -v rustup &>/dev/null; then
    echo "Installing rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    echo "✓ rustup installed"
fi

# bun (JS runtime)
if ! command -v bun &>/dev/null; then
    echo "Installing bun..."
    curl -fsSL https://bun.sh/install | bash
    echo "✓ bun installed"
fi

# uv (Python package manager)
if ! command -v uv &>/dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    echo "✓ uv installed"
fi
EOF
chmod +x /var/home/felix-powerhouse/dotfiles/.chezmoiscripts/run_once_040-install-runtimes.sh
```

- [ ] **Step 6: Write 050-install-ai-agents.sh**

```bash
cat > /var/home/felix-powerhouse/dotfiles/.chezmoiscripts/run_once_050-install-ai-agents.sh << 'EOF'
#!/bin/bash
# Install AI coding agents via npm/bun
set -e

# Ensure npm is available via nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

# Claude Code
if ! command -v claude &>/dev/null; then
    echo "Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code
    echo "✓ claude installed"
fi

# Codex
if ! command -v codex &>/dev/null; then
    echo "Installing Codex..."
    npm install -g @openai/codex
    echo "✓ codex installed"
fi

# OpenCode
if ! command -v opencode &>/dev/null; then
    echo "Installing opencode..."
    npm install -g opencode-ai
    echo "✓ opencode installed"
fi
EOF
chmod +x /var/home/felix-powerhouse/dotfiles/.chezmoiscripts/run_once_050-install-ai-agents.sh
```

- [ ] **Step 7: Commit**

```bash
cd /var/home/felix-powerhouse/dotfiles
git add .chezmoiscripts/run_once_010* .chezmoiscripts/run_once_020* \
    .chezmoiscripts/run_once_030* .chezmoiscripts/run_once_040* \
    .chezmoiscripts/run_once_050*
git commit -m "feat: add common bootstrap scripts (homebrew, cli-tools, cargo, runtimes, ai-agents)"
```

---

## Task 15: Fedora Atomic scripts (060–061 + security)

Migrates from `~/Temp/` scripts with minimal adaptation (add flavor guard + ensure idempotency).

**Files:**
- Create: `.chezmoiscripts/run_once_060-fedora-tailscale.sh.tmpl`
- Create: `.chezmoiscripts/run_once_061-fedora-flatpaks.sh.tmpl`
- Create: `.chezmoiscripts/run_onchange_fedora-security.sh.tmpl`

- [ ] **Step 1: Write 060-fedora-tailscale.sh.tmpl (from Temp/install-tailscale-quick.sh)**

```bash
cat > /var/home/felix-powerhouse/dotfiles/.chezmoiscripts/run_once_060-fedora-tailscale.sh.tmpl << 'TMPL'
#!/bin/bash
{{ if ne .flavor "fedora-atomic" }}exit 0{{ end }}
# Install Tailscale on Fedora Atomic via rpm-ostree layering
set -e

command -v tailscale &>/dev/null && exit 0

echo "Installing Tailscale on Fedora Atomic..."
sudo rpm-ostree install tailscale
echo "✓ Tailscale installed — reboot required to activate"
echo "  After reboot: sudo systemctl enable --now tailscaled && sudo tailscale up"
TMPL
```

- [ ] **Step 2: Write 061-fedora-flatpaks.sh.tmpl**

```bash
cat > /var/home/felix-powerhouse/dotfiles/.chezmoiscripts/run_once_061-fedora-flatpaks.sh.tmpl << 'TMPL'
#!/bin/bash
{{ if ne .flavor "fedora-atomic" }}exit 0{{ end }}
set -e

# Ensure flathub remote is added
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

FLATPAKS=(
    com.vscodium.codium
    org.mozilla.firefox
    com.discordapp.Discord
)

for app in "${FLATPAKS[@]}"; do
    flatpak info "$app" &>/dev/null && continue
    echo "Installing $app..."
    flatpak install -y flathub "$app"
done

echo "✓ Flatpaks installed"
TMPL
```

- [ ] **Step 3: Write run_onchange_fedora-security.sh.tmpl (from Temp/security-hardening.sh)**

```bash
# Copy the existing script as the base and wrap with flavor guard
{
  echo '#!/bin/bash'
  echo '{{ if ne .flavor "fedora-atomic" }}exit 0{{ end }}'
  echo '# Security hardening for Fedora Atomic'
  echo '# Re-runs whenever this script changes (run_onchange_ prefix)'
  echo ''
  # Skip the first shebang line of the original
  tail -n +2 /var/home/felix-powerhouse/Temp/security-hardening.sh
} > /var/home/felix-powerhouse/dotfiles/.chezmoiscripts/run_onchange_fedora-security.sh.tmpl
chmod +x /var/home/felix-powerhouse/dotfiles/.chezmoiscripts/run_onchange_fedora-security.sh.tmpl
```

- [ ] **Step 4: Commit**

```bash
cd /var/home/felix-powerhouse/dotfiles
git add .chezmoiscripts/run_once_060-fedora* .chezmoiscripts/run_once_061-fedora* \
    .chezmoiscripts/run_onchange_fedora*
git commit -m "feat: add Fedora Atomic scripts (tailscale, flatpaks, security)"
```

---

## Task 16: Arch / CachyOS scripts (060–061)

**Files:**
- Create: `.chezmoiscripts/run_once_060-arch-paru.sh.tmpl`
- Create: `.chezmoiscripts/run_once_061-arch-packages.sh.tmpl`

- [ ] **Step 1: Write 060-arch-paru.sh.tmpl**

```bash
cat > /var/home/felix-powerhouse/dotfiles/.chezmoiscripts/run_once_060-arch-paru.sh.tmpl << 'TMPL'
#!/bin/bash
{{ if ne .flavor "arch" }}exit 0{{ end }}
# Install paru AUR helper (works for Arch Linux and CachyOS)
set -e

command -v paru &>/dev/null && exit 0

echo "Installing paru AUR helper..."
sudo pacman -S --needed --noconfirm git base-devel
git clone https://aur.archlinux.org/paru.git /tmp/paru-build
cd /tmp/paru-build && makepkg -si --noconfirm
rm -rf /tmp/paru-build
echo "✓ paru installed"
TMPL
```

- [ ] **Step 2: Write 061-arch-packages.sh.tmpl**

```bash
cat > /var/home/felix-powerhouse/dotfiles/.chezmoiscripts/run_once_061-arch-packages.sh.tmpl << 'TMPL'
#!/bin/bash
{{ if ne .flavor "arch" }}exit 0{{ end }}
# Install core packages on Arch/CachyOS
set -e

# Core system packages via pacman
PACMAN_PKGS=(
    git curl wget unzip zip
    zsh tmux neovim
    base-devel cmake
    openssh
    tailscale
)
sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"

# AUR packages via paru
AUR_PKGS=(
    antidote      # zsh plugin manager
    zoxide        # smart cd
    starship      # prompt
    btop          # resource monitor
)
paru -S --needed --noconfirm "${AUR_PKGS[@]}"

# Enable tailscale
sudo systemctl enable --now tailscaled

echo "✓ Arch packages installed"
TMPL
```

- [ ] **Step 3: Commit**

```bash
cd /var/home/felix-powerhouse/dotfiles
git add .chezmoiscripts/run_once_060-arch* .chezmoiscripts/run_once_061-arch*
git commit -m "feat: add Arch/CachyOS scripts (paru, packages)"
```

---

## Task 17: GNOME DE scripts (080–082)

Migrates catppuccin and tiling shell setup from `~/Temp/`.

**Files:**
- Create: `.chezmoiscripts/run_once_080-gnome-catppuccin.sh.tmpl`
- Create: `.chezmoiscripts/run_once_081-gnome-extensions.sh.tmpl`
- Create: `.chezmoiscripts/run_once_082-gnome-dconf.sh.tmpl`

- [ ] **Step 1: Write 080-gnome-catppuccin.sh.tmpl (from Temp/setup-catppuccin-gnome49.sh)**

```bash
{
  echo '#!/bin/bash'
  echo '{{ if ne .de "gnome" }}exit 0{{ end }}'
  echo '# Install Catppuccin Mocha theme for GNOME'
  echo '# Migrated from Temp/setup-catppuccin-gnome49.sh'
  echo ''
  tail -n +2 /var/home/felix-powerhouse/Temp/setup-catppuccin-gnome49.sh
} > /var/home/felix-powerhouse/dotfiles/.chezmoiscripts/run_once_080-gnome-catppuccin.sh.tmpl
chmod +x /var/home/felix-powerhouse/dotfiles/.chezmoiscripts/run_once_080-gnome-catppuccin.sh.tmpl
```

- [ ] **Step 2: Write 081-gnome-extensions.sh.tmpl (from Temp/configure-tiling-shell.sh)**

```bash
{
  echo '#!/bin/bash'
  echo '{{ if ne .de "gnome" }}exit 0{{ end }}'
  echo '# Install and configure GNOME extensions (tiling, pop-shell)'
  echo '# Migrated from Temp/configure-tiling-shell.sh'
  echo ''
  tail -n +2 /var/home/felix-powerhouse/Temp/configure-tiling-shell.sh
} > /var/home/felix-powerhouse/dotfiles/.chezmoiscripts/run_once_081-gnome-extensions.sh.tmpl
chmod +x /var/home/felix-powerhouse/dotfiles/.chezmoiscripts/run_once_081-gnome-extensions.sh.tmpl
```

- [ ] **Step 3: Write 082-gnome-dconf.sh.tmpl**

```bash
cat > /var/home/felix-powerhouse/dotfiles/.chezmoiscripts/run_once_082-gnome-dconf.sh.tmpl << 'TMPL'
#!/bin/bash
{{ if ne .de "gnome" }}exit 0{{ end }}
# Restore GNOME dconf settings from tracked settings.ini
set -e

SETTINGS="$HOME/.config/dconf/settings.ini"
if [ ! -f "$SETTINGS" ]; then
    echo "dconf settings.ini not found at $SETTINGS — skipping"
    exit 0
fi

echo "Loading dconf settings..."
dconf load / < "$SETTINGS"
echo "✓ dconf settings restored"
echo "  Note: Log out and back in for all settings to take effect"
TMPL
```

- [ ] **Step 4: Commit**

```bash
cd /var/home/felix-powerhouse/dotfiles
git add .chezmoiscripts/run_once_080-gnome* .chezmoiscripts/run_once_081-gnome* \
    .chezmoiscripts/run_once_082-gnome*
git commit -m "feat: add GNOME DE scripts (catppuccin, extensions, dconf)"
```

---

## Task 18: Hyprland + KDE DE scripts

**Files:**
- Create: `.chezmoiscripts/run_once_080-hyprland-deps.sh.tmpl`
- Create: `.chezmoiscripts/run_once_080-kde-catppuccin.sh.tmpl`

- [ ] **Step 1: Write 080-hyprland-deps.sh.tmpl**

```bash
cat > /var/home/felix-powerhouse/dotfiles/.chezmoiscripts/run_once_080-hyprland-deps.sh.tmpl << 'TMPL'
#!/bin/bash
{{ if ne .de "hyprland" }}exit 0{{ end }}
# Install Hyprland ecosystem dependencies
set -e

{{- if eq .flavor "arch" }}
paru -S --needed --noconfirm \
    waybar \
    rofi-wayland \
    dunst \
    hyprlock \
    swayidle \
    hyprpaper \
    swaync \
    clipse
{{- else if eq .flavor "debian" }}
sudo apt install -y \
    waybar \
    rofi \
    dunst
{{- else }}
echo "Hyprland deps: unsupported flavor '{{ .flavor }}' — install manually"
{{- end }}

echo "✓ Hyprland dependencies installed"
TMPL
```

- [ ] **Step 2: Write 080-kde-catppuccin.sh.tmpl**

```bash
cat > /var/home/felix-powerhouse/dotfiles/.chezmoiscripts/run_once_080-kde-catppuccin.sh.tmpl << 'TMPL'
#!/bin/bash
{{ if ne .de "kde" }}exit 0{{ end }}
# Install Catppuccin Mocha theme for KDE Plasma
set -e

echo "Installing Catppuccin Mocha for KDE..."

{{- if eq .flavor "arch" }}
paru -S --needed --noconfirm catppuccin-gtk-theme-mocha kvantum-theme-catppuccin-git
{{- else if eq .flavor "fedora-atomic" }}
# Install via flatpak or manual download
flatpak install -y flathub org.kde.KStyle.Kvantum
{{- end }}

echo "✓ KDE Catppuccin installed — apply via System Settings > Appearance"
TMPL
```

- [ ] **Step 3: Commit**

```bash
cd /var/home/felix-powerhouse/dotfiles
git add .chezmoiscripts/run_once_080-hyprland* .chezmoiscripts/run_once_080-kde*
git commit -m "feat: add Hyprland and KDE DE scripts"
```

---

## Task 19: AI agent configs

Tracks tool configs that have no secrets. API keys are already exported via `env.zsh.tmpl` (Task 4). The `~/.claude.json` stores session metadata, NOT API keys — it is not tracked.

**Files:**
- Create: `dot_config/opencode/opencode.json`
- Create: `dot_codex/config.toml.tmpl`
- Create: `dot_kimi/config.toml`

- [ ] **Step 1: Add opencode config**

```bash
chezmoi add ~/.config/opencode/opencode.json
```

- [ ] **Step 2: Add kimi config (no secrets)**

```bash
chezmoi add ~/.kimi/config.toml
```

- [ ] **Step 3: Write dot_codex/config.toml.tmpl (model only, no machine-specific trust entries)**

```bash
mkdir -p /var/home/felix-powerhouse/dotfiles/dot_codex
cat > /var/home/felix-powerhouse/dotfiles/dot_codex/config.toml.tmpl << 'TMPL'
# Codex configuration — machine-specific [projects] trust entries are NOT tracked
# Add trusted project paths locally after init
model = "gpt-5.4-mini"
model_reasoning_effort = "xhigh"

[notice.model_migrations]
"gpt-5.3-codex" = "gpt-5.4"
TMPL
```

Note: The existing `~/.codex/config.toml` has `[projects."/path/..."]` trust entries that are machine-specific. The template keeps only the model settings.

- [ ] **Step 4: Verify kimi credentials file is NOT added**

```bash
ls /var/home/felix-powerhouse/dotfiles/dot_kimi/
```

Expected: only `config.toml` — no `credentials` file, no session dirs.

- [ ] **Step 5: Commit**

```bash
cd /var/home/felix-powerhouse/dotfiles
git add dot_config/opencode/ dot_codex/ dot_kimi/
git commit -m "feat: add AI agent configs (opencode, codex model, kimi model)"
```

---

## Task 20: Generate consolidated secrets file + validate

This is the final local-only step. Creates `~/.config/chezmoi/chezmoi.toml` with the current machine's real values, then validates with `chezmoi apply`.

**Files:**
- Modify: `~/.config/chezmoi/chezmoi.toml` (local only — never committed)

- [ ] **Step 1: Update local chezmoi.toml with all data + secrets**

You will need your actual API keys for this step. Open the file in an editor:

```bash
nvim ~/.config/chezmoi/chezmoi.toml
```

Replace the contents with (fill in your real values):

```toml
sourceDir = "/var/home/felix-powerhouse/dotfiles"

[data]
  flavor          = "fedora-atomic"
  de              = "gnome"
  gitName         = "Felipe Felix"
  gitEmail        = "felixti@live.com"
  anthropicApiKey = "YOUR_ANTHROPIC_KEY_HERE"
  openaiApiKey    = "YOUR_OPENAI_KEY_HERE"
  kimiApiKey      = "YOUR_KIMI_KEY_HERE"
```

- [ ] **Step 2: Verify permissions on the secrets file**

```bash
ls -la ~/.config/chezmoi/chezmoi.toml
```

Expected: `-rw-------` (600 — owner read/write only). If not:

```bash
chmod 600 ~/.config/chezmoi/chezmoi.toml
```

- [ ] **Step 3: Confirm the consolidated secrets file location**

```bash
echo "Your secrets are at: ~/.config/chezmoi/chezmoi.toml"
echo "Contents (redacted):"
cat ~/.config/chezmoi/chezmoi.toml | sed 's/= "sk-.*/= "***REDACTED***"/g' | sed 's/ApiKey = ".*/ApiKey = "***"/g'
```

- [ ] **Step 4: Run chezmoi diff to preview all changes**

```bash
chezmoi diff 2>&1 | head -60
```

Expected: shows diffs for files that differ between source and `$HOME` (mostly none on this machine since we migrated from existing configs).

- [ ] **Step 5: Run chezmoi apply**

```bash
chezmoi apply --verbose 2>&1 | tail -30
```

Expected: applies changes, exits 0. Template files render correctly with the real values from chezmoi.toml.

- [ ] **Step 6: Verify ANTHROPIC_API_KEY is exported via the template**

```bash
chezmoi execute-template '{{ .anthropicApiKey }}' | wc -c
```

Expected: number > 1 (key is not empty)

- [ ] **Step 7: Run chezmoi doctor**

```bash
chezmoi doctor
```

Expected: all checks pass (green), no errors.

---

## Task 21: Push to GitHub

- [ ] **Step 1: Create GitHub repository**

```bash
gh repo create felixti/dotfiles --private --description "Reproducible dotfiles managed by chezmoi" --confirm
```

Or via web: https://github.com/new → name `dotfiles`, private.

- [ ] **Step 2: Add remote and push**

```bash
cd /var/home/felix-powerhouse/dotfiles
git remote add origin git@github.com:felixti/dotfiles.git
git push -u origin main
```

- [ ] **Step 3: Verify repo is live**

```bash
gh repo view felixti/dotfiles
```

Expected: shows repo name, description, latest commit.

- [ ] **Step 4: Verify no secrets were committed**

```bash
cd /var/home/felix-powerhouse/dotfiles
git log --all --full-history -- "*.toml" | head -5
git grep -i "sk-ant" 2>/dev/null || echo "✓ No Anthropic keys found in repo"
git grep -i "sk-" 2>/dev/null || echo "✓ No API keys found in repo"
```

Expected: all greps return no matches.

- [ ] **Step 5: Test the bootstrap command on a clean path**

```bash
# Simulate what a new machine would do (read-only test)
chezmoi init --dry-run gh:felixti/dotfiles 2>&1 | head -20
```

Expected: shows init plan, no errors.

---

## Appendix: Using on a new machine

```bash
# 1. Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"

# 2. Bootstrap (wizard prompts for flavor, de, identity, secrets)
chezmoi init --apply gh:felixti/dotfiles

# Your consolidated secrets file will be at:
#   ~/.config/chezmoi/chezmoi.toml  (600 permissions, never committed)
```

## Appendix: Day-to-day commands

```bash
chezmoi cd              # open shell in ~/dotfiles
chezmoi diff            # preview pending changes
chezmoi apply           # apply source → $HOME
chezmoi update          # git pull + apply (other machines)
chezmoi add FILE        # start tracking a new file
chezmoi edit FILE       # edit tracked file
chezmoi doctor          # diagnose issues
```
