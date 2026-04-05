# dotfiles

Reproducible machine setup managed by [chezmoi](https://chezmoi.io).

## Quick start

```bash
# 1. Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"

# 2. Bootstrap (prompts for flavor, DE, identity, API keys)
chezmoi init --apply gh:felixti/dotfiles

# 3. Restart shell, then update everything
update
```

The wizard asks for:
- **Distro flavor** — `fedora-atomic` | `arch` | `debian` | `macos`
- **Desktop environment** — `gnome` | `kde` | `hyprland` | `none`
- **File manager** — `yazi` (TUI) | `nemo` (GUI, Catppuccin-styled)
- **Git name + email**
- **API keys** (blank to skip): Anthropic, OpenAI, Kimi, Unsplash

---

## Step-by-step per distro

### Fedora Atomic (Bluefin / Aurora)

**First boot after install:**

```bash
# Update the base OS first
ujust update

# Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"

# Bootstrap (select fedora-atomic, then your DE)
chezmoi init --apply gh:felixti/dotfiles

# Restart shell, then run the unified update
update
```

**What runs automatically:**
- `run_once_010-install-homebrew.sh` — Linuxbrew
- `run_once_020-install-cli-tools.sh` — eza, bat, fd, ripgrep, fzf, starship, zoxide, thefuck
- `run_once_030-install-cargo-tools.sh` — eza, dust, delta, git-delta, grease
- `run_once_040-install-runtimes.sh` — nvm, bun, pnpm
- `run_once_050-install-ai-agents.sh` — opencode, codex, kimi-code
- `run_once_060-fedora-tailscale.sh` — Tailscale
- `run_once_061-fedora-flatpaks.sh` — VSCodium, Firefox, Discord
- `run_once_000-system-update.sh` — installs `update` command + runs it
- `run_once_080-gnome-extensions.sh` — tiling shell + pop-shell
- `run_once_080-gnome-catppuccin.sh` — Catppuccin Mocha theme
- `run_once_082-gnome-dconf.sh` — restore GNOME settings

**Post-apply manual steps:**

| Task | Command |
|---|---|
| Apply GNOME dconf settings | `dconf load / < ~/.config/dconf/settings.ini` then log out/in |
| GPU (AMD RX 6600) | `sudo rpm-ostree install rocm-opencl` then reboot |
| GPU (NVIDIA) | Use Bluefin-Nvidia image or `ublue-update` |

**Reference:** [Bluefin docs](https://docs.fedoraproject.org/en-US/bluefin/) · [Aurora docs](https://docs.getaurora.dev/)

---

### Arch Linux / CachyOS

**First boot after install:**

```bash
# Update keyring first (required before any pacman update)
sudo pacman -Sy archlinux-keyring

# Install chezmoi and paru (AUR helper)
sh -c "$(curl -fsLS get.chezmoi.io)"
git clone https://aur.archlinux.org/paru.git /tmp/paru && cd /tmp/paru && makepkg -si

# Bootstrap (select arch, then your DE)
chezmoi init --apply gh:felixti/dotfiles

# Restart shell, then update
update
```

**What runs automatically (Arch):**
- `run_once_010-install-homebrew.sh`
- `run_once_020-install-cli-tools.sh`
- `run_once_030-install-cargo-tools.sh`
- `run_once_040-install-runtimes.sh`
- `run_once_050-install-ai-agents.sh`
- `run_once_060-arch-paru.sh` — installs paru
- `run_once_061-arch-packages.sh` — additional Arch packages
- `run_once_061-fedora-flatpaks.sh` — Flatpaks (Flathub)
- `run_once_000-system-update.sh`
- DE-specific scripts (gnome/kde/hyprland)

**Post-apply manual steps:**

| Task | Command |
|---|---|
| Enable Krohnkite (KDE) | System Settings → Window Management → KWin Scripts → Krohnkite |
| GPU (AMD on CachyOS) | `sudo chwd -a` — auto-detects and installs correct drivers |
| GPU (AMD on Arch) | `paru -S rocm-opencl-runtime amdvlk` |
| GPU (NVIDIA) | `paru -S nvidia` |

**CachyOS specific:** CachyOS ships with Wayland by default. The Hyprland setup is a natural fit. Use `sudo chwd -a` for automatic GPU driver setup including ROCm.

**Reference:** [Arch Wiki](https://wiki.archlinux.org/) · [CachyOS Wiki](https://wiki.cachyos.org/)

---

### Debian / Ubuntu / Pop!_OS

**First boot after install:**

```bash
# Install build dependencies for Homebrew
sudo apt update && sudo apt install -y build-essential curl git

# Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"

# Bootstrap (select debian, then your DE)
chezmoi init --apply gh:felixti/dotfiles

# Restart shell, then update
update
```

**What runs automatically (Debian):**
- `run_once_010-install-homebrew.sh` — builds from source (first)
- `run_once_020-install-cli-tools.sh`
- `run_once_030-install-cargo-tools.sh`
- `run_once_040-install-runtimes.sh`
- `run_once_050-install-ai-agents.sh`
- `run_once_061-fedora-flatpaks.sh` — installs flatpak + Flathub + apps
- `run_once_000-system-update.sh`
- DE-specific scripts

**Post-apply manual steps:**

| Task | Command |
|---|---|
| Flatpak theming | flatpaks pick up Catppuccin from `~/.themes` automatically |
| GPU (AMD) | Install [ROCm from AMD's official repo](https://docs.amd.com/en/latest/deploy/linux/install-data.html) |
| Hyprland (source build) | deps are installed automatically; Hyprland is built from source |

**Reference:** [Debian AMD ROCm](https://docs.amd.com/en/latest/deploy/linux/install-data.html)

---

### macOS

```bash
# Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"

# Bootstrap (select macos, then DE=none)
chezmoi init --apply gh:felixti/dotfiles

# Restart shell
```

**What runs automatically (macOS):**
- `run_once_010-install-homebrew.sh`
- `run_once_020-install-cli-tools.sh`
- `run_once_030-install-cargo-tools.sh`
- `run_once_040-install-runtimes.sh`
- `run_once_050-install-ai-agents.sh`

Homebrew on macOS uses `/opt/homebrew/bin/brew`. All CLI tools (nvim, tmux, starship, zoxide, etc.) are installed via Homebrew.

**macOS does NOT run:** system update scripts, flatpak scripts, DE scripts, Tailscale.

---

## Day-to-day commands

```bash
update              # Update all layers (dotfiles + brew + OS + runtimes)
chezmoi cd         # Open shell in source directory
chezmoi diff       # Preview pending changes
chezmoi apply      # Apply source → $HOME
chezmoi update     # Git pull + apply on other machines
chezmoi add FILE   # Start tracking a new file
chezmoi edit FILE  # Edit a tracked file
chezmoi doctor     # Diagnose issues
```

### Shell aliases

```bash
ll                 # eza -lah --git --icons (modern ls)
ls                 # eza --icons
cat                # bat (syntax-highlighted cat)
cd                 # zoxide (smart cd)
fm                 # yazi (TUI file manager)
yy                 # yazi with auto cd-on-quit
lt                 # eza tree
grep               # ripgrep (smart case, follows, hidden)
update             # ~/.local/bin/update — all layers
```

---

## Adding a new secret

1. Add key to `secrets.example.toml` (commit this)
2. Add key + value to `~/.config/chezmoi/chezmoi.toml` (never commit)
3. Reference in a template: `{{ .newApiKey }}`
4. `chezmoi apply`

---

## Structure overview

```
bin/
└── update.sh                 # Unified update script (all layers)

dot_config/zsh/               # zsh config (main.zsh, aliases, completions)
private_dot_config/zsh/       # private: env.zsh, tools.zsh (API keys, PATH)

dot_config/tmux/              # tmux + catppuccin theme
dot_config/nvim/              # AstroNvim
dot_config/ghostty/           # Ghostty terminal
dot_config/kitty/             # Kitty terminal
dot_config/starship/           # Starship prompt themes
dot_config/yazi/               # Yazi file manager
dot_config/television/         # television fuzzy TUI
dot_config/btop/              # btop
dot_config/glow/              # glow markdown reader
dot_config/thefuck/           # thefuck
dot_config/gh/                # GitHub CLI

# DE-specific (guarded by .chezmoiignore — only applied to matching DE)
private_dot_config/dconf/     # GNOME: dconf settings dump
private_dot_config/pop-shell/ # GNOME: tiling extension
private_dot_config/gtk-3.0/   # GNOME/KDE: GTK3 theme overrides
private_dot_config/gtk-4.0/   # GNOME/KDE: GTK4 theme overrides
private_dot_config/hypr/      # Hyprland: modular HyDE config
private_dot_config/waybar/    # Hyprland: waybar status bar
private_dot_config/wofi/      # Hyprland: wofi app launcher
private_dot_config/kde/       # KDE: kwinrc, kdeglobals, kwinrulesrc
private_dot_config/sddm/      # KDE: SDDM greeter (HyDE sddm-hyprland)
```

---

## What's NOT tracked

- `~/.config/gh/hosts.yml` — GitHub tokens
- `~/.ssh/` — SSH keys
- `~/.claude.json` — session metadata (rendered from template at apply time)
- `~/.zsh_history` — personal shell history

---

## Platform notes

Detailed per-distro hints are in [docs/PLATFORMS.md](docs/PLATFORMS.md):

- Fedora Atomic: rpm-ostree layering, Flatpak, dconf, GPU (AMD RX 6600, NVIDIA)
- Arch / CachyOS: paru AUR, chwd GPU auto-setup, CachyOS Wayland notes
- Debian / Ubuntu: Flatpak install, AMD GPU ROCm
- GNOME: dconf dump/restore, extensions, Catppuccin
- KDE: Krohnkite tiling, Catppuccin, plasma CLI tools, Breeze GTK sync
- Hyprland: per-distro install (COPR, source build), HyDE modular config, SDDM greeter, wallpaper carousel (swww + Unsplash)
- GPU quick reference table: AMD RX 6600, NVIDIA, Intel across all distros
