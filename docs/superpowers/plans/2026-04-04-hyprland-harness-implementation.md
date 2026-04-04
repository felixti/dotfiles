# Hyprland Harness — Implementation Plan

Date: 2026-04-04
Spec: `docs/superpowers/specs/2026-04-04-hyprland-harness-design.md`
Status: in progress

---

## Task Graph

```
[#16] Refactor hyprland.conf into HyDE modular structure
  ├── → [#17] Create Catppuccin Mocha waybar config
  ├── → [#22] Create Catppuccin Mocha wofi config
  ├── → [#21] Create wallpaper-fetch.sh and theme-switcher.sh scripts
  └── → [#19] Create run_once_080-hyprland-sddm.sh.tmpl

[#18] Rewrite run_once_080-hyprland-deps.sh.tmpl with full distro support
  └── (independent — can run in parallel with #16)

[#20] Add unsplashApiKey to secrets and update PLATFORMS.md
  └── (independent — can run in parallel with all)
```

Order: Execute #18 and #16 first (foundation), then the dependents. #20 is always-independent and can run alongside everything.

---

## Task #18 — Rewrite `run_once_080-hyprland-deps.sh.tmpl`

**Goal:** Full per-distro dependency installer for Hyprland ecosystem.

**Actions:**
- Guard: `{{ if ne .de "hyprland" }}exit 0{{ end }}` + `{{ if eq .flavor "darwin" }}exit 0{{ end }}`
- `arch`:
  - `pacman -S hyprland`
  - CachyOS extras (guard on `if command -v pacman &>/dev/null && pacman -Q hyprland-qtutils &>/dev/null` or check for `/etc/cachyos-release`): `hyprland-qtutils hyprlock hypridle hyprpicker hyprsunset hyprcursor`
  - AUR via `paru`: `waybar rofi-wayland dunst swww wlogout brightnessctl ddcutil blueman`
- `fedora-atomic` + `fedora` (non-atomic):
  - `sudo dnf copr enable solopasha/hyprland`
  - `sudo dnf install hyprland hyprpaper hyprlock hypridle hyprpicker`
  - `sudo dnf install waybar rofi dunst swww wlogout brightnessctl ddcutil blueman`
- `debian`:
  - Build deps: `sudo apt install -y build-essential cmake meson ninja-build libwayland-dev libxkbcommon-dev libdisplay-dev libliftoff-dev libinput-dev libhyprutils-dev libegl-dev libgl-dev libgles-dev libpixman-1-dev pkg-config`
  - Clone: `git clone --depth=1 --branch v0.54.1 https://github.com/hyprwm/hyprland /tmp/hyprland`
  - Build: `cd /tmp/hyprland && meson setup build && ninja -C build && sudo ninja -C build install`
  - Install tools: `sudo apt install -y wayland-protocols libwlroots-dev wlogout brightnessctl ddcutil blueman` (note: swww may need source build too)
- `darwin`: exit 0

**New file:** `.chezmoiscripts/run_once_080-hyprland-deps.sh.tmpl` (replace existing).

---

## Task #16 — Refactor `hyprland.conf` into HyDE Modular Structure

**Goal:** Split the existing 336-line single `hyprland.conf` into modular sub-files per HyDE layout, keeping existing vim binds.

**New files** in `private_dot_config/hypr/`:

### `private_dot_config/hypr/hyprland.conf.tmpl`
```hypr
source = ~/.config/hypr/themes/mocha.conf
source = ~/.config/hypr/environment.conf
source = ~/.config/hypr/autostart.conf
source = ~/.config/hypr/keybindings.conf
source = ~/.config/hypr/windowrules.conf
```
- All remaining content from the existing conf goes into the appropriate sourced file.
- Remove `$menu = wofi --show drun` since wofi config now lives in `wofi/config`.
- Keep monitor line: `monitor=HDMI-A-1,2560x1440@144.00Hz,auto,auto`

### `private_dot_config/hypr/themes/mocha.conf`
Full Catppuccin Mocha variables:
```hypr
$rosewater = rgb(242, 213, 206)
$flamingo  = rgb(242, 189, 214)
$mauve     = rgb(203, 166, 247)
$peachy    = rgb(255, 198, 190)
$maroon    = rgb(235, 160, 172)
$text      = rgb(230, 229, 243)
$subtext1  = rgb(205, 202, 230)
...
```
Replace all `$color` references in existing conf with these names.

### `private_dot_config/hypr/environment.conf`
```hypr
env = XCURSOR_SIZE,24
env = QT_QPA_PLATFORMTHEME,qt6ct
env = GBM_BACKEND,nvidia-drm
env = LIBVA_DRIVER_NAME,nvidia
```
GPU env vars guarded: AMD GPU → skip nvidia vars; NVIDIA → set them.

### `private_dot_config/hypr/autostart.conf`
```hypr
exec-once = waybar &
exec-once = swww-daemon &
exec-once = hypridle &
exec-once = blueman-applet &
exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
exec-once = hyprctl setcursor catppuccin-mocha-dark-cursors 28
```

### `private_dot_config/hypr/keybindings.conf`
All binds from existing conf, plus:
```hypr
# Power menu
bind = $mainMod SHIFT, Q, exec, wlogout
# Wallpaper fetch
bind = $mainMod ALT, W, exec, ~/.config/hypr/scripts/wallpaper-fetch.sh
# Theme switcher
bind = $mainMod SHIFT, T, exec, ~/.config/hypr/scripts/theme-switcher.sh
```
Remove `bind = $SUPER_SHIFT, l, exec, hyprlock` (keep hyprlock in autostart instead).

### `private_dot_config/hypr/windowrules.conf`
Float/size rules extracted from existing conf:
```hypr
windowrulev2 = suppressevent maximize, class:.*
windowrulev2 = nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0
windowrulev2 = float, class:(clipse)
windowrulev2 = size 622 652, class:(clipse)
```

### Scripts subdir
Create `private_dot_config/hypr/scripts/` (directory marker):
- `private_dot_config/hypr/scripts/.gitkeep` — ensures directory is tracked by git

---

## Task #22 — Catppuccin Mocha Wofi Config

**New file:** `private_dot_config/wofi/config` (note: no `.tmpl` extension since it's just a config file, not executable):

```
width=600
location=center
show=drun
no-sort=true
allow-markup=true
format-markup=true
halign=fill
orientation=horizontal
content-halign=fill
insensitive=true
allow-images=true
image-size=32
gtk-dark=true
```

Style via CSS in `~/.config/wofi/style.css` (created separately). Catppuccin Mocha colors:
- background: `#1e1e28`
- foreground: `#cdd6f4`
- selected: `#313244`
- border: `#45475a`

---

## Task #21 — Wallpaper Fetch and Theme Switcher Scripts

### `private_dot_config/hypr/scripts/wallpaper-fetch.sh.tmpl`
```bash
#!/usr/bin/env bash
set -e

WALLPAPER_DIR="$HOME/.wallpaper"
WALLPAPER="$WALLPAPER_DIR/current.jpg"
mkdir -p "$WALLPAPER_DIR"

{{- if .unsplashApiKey }}
QUERY="nature,dark,minimal"
URL="https://api.unsplash.com/photos/random?query=$QUERY&orientation=landscape"
curl -s -H "Authorization: Client-ID {{ .unsplashApiKey }}" \
     "$URL" | jq -r '.urls.raw + "&w=2560&q=80"' | xargs -I{} curl -sL {} -o "$WALLPAPER"
swww img "$WALLPAPER" --transition-type random
{{- else }}
echo "No unsplashApiKey — skipping wallpaper fetch"
{{- end }}
```

### `private_dot_config/hypr/scripts/theme-switcher.sh.tmpl`
```bash
#!/usr/bin/env bash
THEMES_DIR="$HOME/.config/hypr/themes"
CURRENT=$(grep "^source=" "$HOME/.config/hypr/hyprland.conf" | head -1 | sed 's/source = //')
# Cycle: mocha.conf → (back to mocha.conf)
case "$CURRENT" in
  "$THEMES_DIR/mocha.conf") NEW="$THEMES_DIR/mocha.conf" ;;
  *) NEW="$THEMES_DIR/mocha.conf" ;;
esac
sed -i "1s|.*|source = $NEW|" "$HOME/.config/hypr/hyprland.conf"
hyprctl reload
```

---

## Task #19 — SDDM Installer Script

**New file:** `.chezmoiscripts/run_once_080-hyprland-sddm.sh.tmpl`

```bash
#!/bin/bash
{{ if or (ne .de "hyprland") (eq .flavor "darwin") }}exit 0{{ end }}
set -e

# Install SDDM
{{- if eq .flavor "arch" }}
sudo pacman -S --noconfirm sddm
{{- else if eq .flavor "fedora-atomic" }}
sudo rpm-ostree install sddm
{{- else if eq .flavor "fedora" }}
sudo dnf install -y sddm
{{- else if eq .flavor "debian" }}
sudo apt install -y sddm
{{- end }}

# Clone and install HyDE sddm theme
SDDM_DIR="/tmp/sddm-hyprland"
rm -rf "$SDDM_DIR"
git clone --depth=1 https://github.com/HyDE-Project/sddm-hyprland "$SDDM_DIR"
sudo cp -r "$SDDM_DIR"/themes/* /usr/share/sddm/themes/
sudo sed -i 's/^Current=.*/Current=hyprland/' /etc/sddm.conf

# Enable SDDM
sudo systemctl enable sddm
echo "✓ SDDM + HyDE greeter installed — reboot to use"
```

---

## Task #17 — Catppuccin Mocha Waybar Config

**New files:**
- `private_dot_config/waybar/config` — JSON config with modules
- `private_dot_config/waybar/style.css` — Catppuccin Mocha CSS

**Modules:**
```json
"modules-left": ["hypr/workspaces"],
"modules-center": ["hypr/window"],
"modules-right": ["pulseaudio", "backlight", "cpu", "memory", "temperature", "clock"]
```

For laptops add `"battery"`. For bluetooth use blueman module.

**Catppuccin Mocha CSS** (fragments from Catppuccin waybar docs):
```css
* { font-family: JetBrains Mono, FontAwesome; font-size: 13px; }
#window { color: #cdd6f4; }
#workspaces button { color: #cdd6f4; background: transparent; border-radius: 4px; }
#workspaces button.active { color: #1e1e28; background: #cba6f7; }
#clock, #battery, #cpu, #memory, #temperature, #backlight, #pulseaudio { color: #cdd6f4; background: #313244; margin: 0 4px; padding: 0 8px; border-radius: 4px; }
#pulseaudio.muted { color: #f38ba8; }
```

---

## Task #20 — Secrets and PLATFORMS.md

**`secrets.example.toml`:** Add `unsplashApiKey = "" # Unsplash API key — free tier at unsplash.com/developers`

**`docs/PLATFORMS.md`:** Add new section:

```markdown
## Desktop Environment: Hyprland

**Install methods per distro:**

| Flavor | Command |
|---|---|
| Arch/CachyOS | `pacman -S hyprland` (+ CachyOS extras) |
| Fedora | `sudo dnf copr enable solopasha/hyprland && sudo dnf install hyprland` |
| Debian/Ubuntu | Source build from Hyprland GitHub releases |

**Tracked configs:** `hypr/`, `waybar/`, `wofi/`

**Scripts:**
- `run_once_080-hyprland-deps.sh.tmpl` — install all Hyprland ecosystem deps
- `run_once_080-hyprland-sddm.sh.tmpl` — SDDM + HyDE greeter

**References:**
- [HyDE-Project/HyDE](https://github.com/HyDE-Project/HyDE)
- [HyDE sddm-hyprland](https://github.com/HyDE-Project/sddm-hyprland)
- [hyprpaper-unsplash](https://github.com/qwertzui11/hyprpaper-wallpaper-fetcher)
```
