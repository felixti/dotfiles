# dotfiles

Reproducible machine setup managed by [chezmoi](https://chezmoi.io).

## Quick start

```bash
# 1. Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"

# 2. Bootstrap (prompts for flavor, DE, identity, API keys)
chezmoi init --apply https://github.com/felixti/dotfiles

# 3. Restart shell, then update everything
update
```

The wizard asks for:
- **Distro flavor** — `fedora-atomic` | `arch` | `debian` | `macos`
- **Desktop environment** — `gnome` | `kde` | `hyprland` | `none`
- **File manager** — `yazi` (TUI) | `nemo` (GUI, Catppuccin-styled)
- **Git name + email**
- **Unsplash API key** (blank to skip) — for wallpaper-fetch

AI tools (Claude Code, Codex, Kimi) authenticate via OAuth subscription — no API keys needed.

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
chezmoi init --apply https://github.com/felixti/dotfiles

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
- `run_once_005-ensure-zsh.sh` — ensures zsh is installed and set as default shell
- `run_once_000-system-update.sh` — installs `update` command + runs it
- `run_once_080-gnome-extensions.sh` — tiling shell + pop-shell
- `run_once_080-gnome-catppuccin.sh` — Catppuccin Mocha theme
- `run_once_082-gnome-dconf.sh` — restore GNOME settings

**Post-apply manual steps:**

| Task | Command |
|---|---|
| Log out and back in | Required for zsh to become your login shell (run_once_005) |
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
chezmoi init --apply https://github.com/felixti/dotfiles

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
- `run_once_005-ensure-zsh.sh` — ensures zsh is installed and set as default shell
- `run_once_061-arch-packages.sh` — additional Arch packages
- `run_once_061-fedora-flatpaks.sh` — Flatpaks (Flathub)
- `run_once_000-system-update.sh`
- DE-specific scripts (gnome/kde/hyprland)

**Post-apply manual steps:**

| Task | Command |
|---|---|
| Log out and back in | Required for zsh to become your login shell (run_once_005) |
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
chezmoi init --apply https://github.com/felixti/dotfiles

# Restart shell, then update
update
```

**What runs automatically (Debian):**
- `run_once_010-install-homebrew.sh` — builds from source (first)
- `run_once_020-install-cli-tools.sh`
- `run_once_030-install-cargo-tools.sh`
- `run_once_040-install-runtimes.sh`
- `run_once_050-install-ai-agents.sh`
- `run_once_005-ensure-zsh.sh` — ensures zsh is installed and set as default shell
- `run_once_061-fedora-flatpaks.sh` — installs flatpak + Flathub + apps
- `run_once_000-system-update.sh`
- DE-specific scripts

**Post-apply manual steps:**

| Task | Command |
|---|---|
| Log out and back in | Required for zsh to become your login shell (run_once_005) |
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
chezmoi init --apply https://github.com/felixti/dotfiles

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
ts                 # tailscale
tsw                # tmux session switcher (fzf)
lg                 # lazygit
update             # ~/.local/bin/update — all layers
```

---

## Adding a new template variable

1. Add prompt to `.chezmoi.toml.tmpl` and its `[data]` block
2. Add to `secrets.example.toml` with a comment (commit this)
3. Add real value to `~/.config/chezmoi/chezmoi.toml` (never commit)
4. Reference in templates: `{{ .varName }}`
5. `chezmoi apply`

---

## Structure overview

```
bin/
└── update.sh.tmpl            # Unified update script (all layers)

private_dot_config/zsh/       # Modular zsh config (env, aliases, functions, tools, tmux, starship)
  └── completions/            # Shell completions (bat, eza, fd, rg, tailscale, yazi)

private_dot_config/tmux/      # tmux + Catppuccin theme
private_dot_config/nvim/      # AstroNvim v4
private_dot_config/ghostty/   # Ghostty terminal
private_dot_config/kitty/     # Kitty terminal
private_dot_config/starship/  # 3 Starship prompt themes (minimal, developer, cyber)
private_dot_config/yazi/      # Yazi file manager
private_dot_config/television/ # television fuzzy TUI
private_dot_config/btop/      # btop
private_dot_config/glow/      # glow markdown reader
private_dot_config/thefuck/   # thefuck
private_dot_config/gh/        # GitHub CLI

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
private_dot_config/nemo/      # Nemo: Catppuccin CSS (guarded by fileManager)
```

---

## What's NOT tracked

- `~/.config/chezmoi/chezmoi.toml` — real template variable values (secrets)
- `~/.config/gh/hosts.yml` — GitHub tokens
- `~/.ssh/` — SSH keys
- `~/.zsh_history` — personal shell history

---

## Troubleshooting

### Re-run failed setup scripts

`run_once_` scripts execute exactly once. If one fails mid-bootstrap (network issue, etc.), chezmoi marks it as done. To re-trigger:
```bash
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

### chezmoi apply skips expected files

Files are conditionally excluded based on `de` and `fileManager`. Check your settings:
```bash
chezmoi data | grep -E "de|flavor|fileManager"
```

### Change bootstrap answers after init

Edit `~/.config/chezmoi/chezmoi.toml` directly, then `chezmoi apply`.

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
