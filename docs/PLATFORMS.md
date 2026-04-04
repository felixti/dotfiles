# Platform Notes

Platform-specific hints, caveats, and troubleshooting for each supported flavor and DE combination.

---

## fedora-atomic

**Distros:** Bluefin (GNOME), Aurora (KDE)

**Package manager:** `rpm-ostree` (immutable OS), Homebrew for user-space tools

### rpm-ostree layering

Tools like Tailscale, Node.js, and ROCm can be layered into the base OS image:

```bash
sudo rpm-ostree install tailscale
sudo rpm-ostree install rocm-opencl  # AMD GPU
```

**Reboot required** after layering — changes don't go live until next boot.

### Flatpak

Flatpak works natively. Flathub remote is added automatically by `run_once_061-fedora-flatpaks.sh`.

### DConf (GNOME)

GNOME settings are exported as a `.ini` file and restored via:
```bash
dconf load / < ~/.config/dconf/settings.ini
```
Log out and back in for all settings to take effect.

### GPU: AMD RX 6600 (RDNA2)

ROCm support on Fedora Atomic:
```bash
sudo rpm-ostree install rocm-opencl
# Reboot required
clinfo | grep "GPU"   # verify
```

For NVIDIA: use the NVIDIA Atomic variant or `ublue-update`.

### GPU: NVIDIA

Use Bluefin-Nvidia or switch to an Atomic variant that includes NVIDIA drivers pre-configured. `rpm-ostree` layering for NVIDIA can be complex.

---

## arch

**Distros:** Arch Linux, CachyOS, EndeavourOS

**Package manager:** `pacman`, AUR via `paru`

### paru AUR helper

`paru` is installed by `run_once_060-arch-paru.sh.tmpl` — it's configured with:
```
# ~/.config/paru/paru.conf
SudoLoop = true
```

### CachyOS specifics

CachyOS ships with [Wayland by default](https://cachyos.org/blog/2601-january-release) (KDE Plasma on Wayland). Standard X11 configs still apply but Wayland-native configs may differ.

**GPU auto-setup:** CachyOS provides `chwd` (Hardware Detection tool) that auto-detects and configures AMD GPUs:
```bash
sudo chwd -a   # auto-detect all GPUs, install correct drivers
```
This also handles ROCm automatically for [ROCm-supported AMD GPUs](https://wiki.cachyos.org/features/chwd/gpu_migration/).

### GPU: AMD RX 6600 (RDNA2) on Arch/CachyOS

On **CachyOS**: use `chwd` — it's the cleanest path:
```bash
sudo chwd -a
```

On **standard Arch**: install ROCm manually:
```bash
paru -S --noconfirm rocm-opencl-runtime
# Verify
clinfo | grep "GPU"
```

### Krohnkite tiling (KDE)

Krohnkite is [available as an AUR package](https://aur.archlinux.org/packages/kwin-scripts-krohnkite/) (v0.9.9.2-3, Plasma 6 compatible):

```bash
paru -S --noconfirm kwin-scripts-krohnkite
```

Enable in **System Settings → Window Management → KWin Scripts → Krohnkite**.

The [Codeberg fork](https://codeberg.org/anametologin/Krohnkite) is the active development version for Plasma 6.

### Catppuccin KDE

Install via the official installer or AUR:

```bash
# Official method
git clone --depth=1 https://github.com/catppuccin/kde
cd kde && ./install.sh

# AUR (Arch)
paru -S --noconfirm catppuccin-plasma-colorscheme-mocha
```

Apply with:
```bash
plasma-apply-lookandfeel --apply Catppuccin-Mocha-Mauve.desktop
```

---

## debian

**Distros:** Debian, Ubuntu, Pop!_OS

**Package manager:** `apt`, Homebrew

### Flatpak on Debian/Ubuntu

Flatpak is not installed by default. `run_once_061-fedora-flatpaks.sh.tmpl` installs it via `apt install flatpak`.

Flathub remote is added automatically.

### KDE on Pop!_OS

Pop!_OS uses its own desktop environment (COSMIC). Standard KDE Plasma install works but may conflict with COSMIC defaults.

### GPU: AMD on Debian

AMD GPU support on Debian may require backports or manual ROCm install:
```bash
sudo apt install clinfo
# ROCm from AMD's official repo: https://docs.amd.com/en/latest/deploy/linux/install-data.html
```

---

## macOS

**Package manager:** Homebrew (`brew`)

### chezmoi.os value

chezmoi detects macOS as `darwin`. All Homebrew paths use `/opt/homebrew/` (Apple Silicon) or `/usr/local/` (Intel).

### GitHub CLI credentials

On macOS, `gh` stores credentials in the macOS Keychain. The `hosts.yml` approach (Linux) does not apply.

### AI agents

AI coding agents that require Node.js: nvm is installed via `run_once_040-install-runtimes.sh`.

---

## Desktop Environment: GNOME

**Tracked configs:**
- `pop-shell/` — tiling extension
- `gtk-3.0/settings.ini` — GTK theme
- `gtk-4.0/settings.ini` — GTK4 theme
- `org.gnome.Ptyxis/` — GNOME terminal
- `dconf/settings.ini` — full dconf dump

**Scripts:**
- `run_once_080-gnome-catppuccin.sh.tmpl` — Catppuccin Mocha theme
- `run_once_081-gnome-extensions.sh.tmpl` — pop-shell, tiling-shell
- `run_once_082-gnome-dconf.sh.tmpl` — restore dconf settings

**DConf dump/restore:**
```bash
# Export
dconf dump / > settings.ini

# Import
dconf load / < settings.ini
```

---

## Desktop Environment: KDE

**Tracked configs:**
- `kde/kwinrc` — KWin window manager
- `kde/kwinrulesrc` — Window rules
- `kde/kdeglobals` — Global KDE settings (colors, fonts, shortcuts)

**Scripts:**
- `run_once_080-kde-catppuccin.sh.tmpl` — Catppuccin Mocha for KDE
- `run_once_080-kde-gtk-sync.sh.tmpl` — Breeze GTK sync for GTK apps
- `run_once_080-kde-kwin.sh.tmpl` — Krohnkite tiling + vim keybinds
- `run_once_080-kde-gpu.sh.tmpl` — AMD GPU/ROCm setup

### KDE Theme Application (CLI)

```bash
# Apply full look-and-feel package
plasma-apply-lookandfeel --apply Catppuccin-Mocha-Mauve.desktop

# Apply color scheme only
plasma-apply-colorscheme Catppuccin-Mocha-Mauve.colors

# List available schemes
plasma-apply-lookandfeel --list
```

### KWin Configuration

```bash
# Reload KWin config without logout
qdbus6 org.kde.KWin /KWin reconfigure

# Or
qdbus6 org.kde.KWin /KWin restart   # full restart
```

### KWin Shortcuts (vim-style tiling)

Default Krohnkite bindings (dwm-style):

| Key | Action |
|-----|--------|
| `Meta+J/K` | Focus down/up |
| `Meta+H/L` | Focus left/right |
| `Meta+Shift+J/K` | Move window down/up |
| `Meta+Shift+H/L` | Move window left/right |
| `Meta+F` | Toggle floating |
| `Meta+M` | Monocle layout |
| `Meta+T` | Reset tiling |
| `Meta+\` | Cycle layout |

### GTK App Theme Sync on KDE

```bash
# Install breeze-gtk (Fedora)
sudo dnf install breeze-gtk

# Install kde-gtk-config (auto-syncs KDE theme to GTK apps)
sudo dnf install kde-gtk-config

# Or on Arch
paru -S breeze-gtk kde-gtk-config
```

GTK app theme is then set via **System Settings → Application Style → GNOME Application Style → Breeze**.

---

## Desktop Environment: Hyprland

**Install methods per distro:**

| Flavor | Command |
|---|---|
| Arch/CachyOS | `pacman -S hyprland` (+ CachyOS extras: hyprland-qtutils, hyprlock, hypridle, hyprpicker, hyprsunset, hyprcursor) |
| Fedora Atomic | `sudo rpm-ostree install sddm hyprland && sudo dnf copr enable solopasha/hyprland` |
| Fedora (non-Atomic) | `sudo dnf copr enable solopasha/hyprland && sudo dnf install hyprland` |
| Debian/Ubuntu | Source build: build deps → git clone v0.54.1 → meson build → ninja install |

**Tracked configs:** `hypr/`, `waybar/`, `wofi/`

**Scripts:**
- `run_once_080-hyprland-deps.sh.tmpl` — install all Hyprland ecosystem deps per distro
- `run_once_080-hyprland-sddm.sh.tmpl` — SDDM + HyDE greeter for Arch and Fedora

**References:**
- [HyDE-Project/HyDE](https://github.com/HyDE-Project/HyDE)
- [HyDE sddm-hyprland](https://github.com/HyDE-Project/sddm-hyprland)
- [hyprpaper-unsplash wallpaper fetcher](https://github.com/qwertzui11/hyprpaper-wallpaper-fetcher)

---

## GPU Quick Reference

| GPU | Fedora Atomic | Arch / CachyOS | Debian / Ubuntu |
|-----|---------------|-----------------|-----------------|
| **AMD RX 6600** | `rpm-ostree install rocm-opencl` | `sudo chwd -a` (CachyOS) or `paru -S rocm-opencl-runtime` | AMD official ROCm repo |
| **NVIDIA** | Bluefin-Nvidia variant | `paru -S nvidia` | `ubuntu-drivers autoinstall` |
| **Intel** | Built-in | `pacman -S intel-media-driver` | `apt install intel-media-va-driver` |

CachyOS `chwd` reference: [wiki.cachyos.org/features/chwd/gpu_migration](https://wiki.cachyos.org/features/chwd/gpu_migration/)

---

## References

- [Catppuccin KDE GitHub](https://github.com/catppuccin/kde)
- [AUR: kwin-scripts-krohnkite](https://aur.archlinux.org/packages/kwin-scripts-krohnkite/)
- [anametologin/Krohnkite (Plasma 6 fork)](https://codeberg.org/anametologin/Krohnkite)
- [CachyOS GPU Switching](https://wiki.cachyos.org/features/chwd/gpu_migration/)
- [CachyOS January 2026 Release](https://cachyos.org/blog/2601-january-release)
- [KDE System Administration/Config Files](https://userbase.kde.org/KDE_System_Administration/Configuration_Files)
- [KWin Scripting Tutorial](https://develop.kde.org/docs/plasma/kwin/)
- [Konsave - KDE Config Saver](https://github.com/Prayag2/konsave)
- [breeze-gtk (GitHub)](https://github.com/KDE/breeze-gtk)
