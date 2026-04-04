# Hyprland Harness Design

Date: 2026-04-04
Status: approved

---

## Overview

Full Hyprland desktop harness for the chezmoi dotfiles, supporting 4 distro flavors across 4 desktop environments. HyDE's modular config structure as the foundation, Catppuccin Mocha as the single theme, vim keybindings throughout, and a wallpaper carousel from Unsplash.

---

## Distro Support

| Flavor | Method | Notes |
|---|---|---|
| **arch** | `pacman -S hyprland` + CachyOS extras | Main repo hyprland + CachyOS-specific: `hyprland-qtutils`, `hyprlock`, `hypridle`, `hyprpicker`, `hyprsunset`, `hyprcursor`. AUR via `paru`: waybar, rofi-wayland, dunst, swww, wlogout, brightnessctl, ddcutil, bluman |
| **fedora-atomic** | COPR `solopasha/hyprland` | Same tool list via `dnf` |
| **debian** | Source build from Hyprland GitHub | Build deps → git clone → meson build → ninja install |
| **macos** | `exit 0` | Wayland not supported |

---

## Config File Layout

```
private_dot_config/hypr/
├── hyprland.conf           # main entry, sources all sub-confs
├── keybindings.conf        # vim binds (h/j/k/l) + HyDE extras
├── windowrules.conf        # float/size rules per app
├── autostart.conf          # exec-once daemons (waybar, swww, hypridle, etc.)
├── environment.conf        # env vars (XCURSOR, QT_QPA_PLATFORMTHEME, GPU vars)
├── wofi/
│   └── config              # Catppuccin Mocha wofi styling
├── themes/
│   └── mocha.conf          # Catppuccin Mocha color variables
└── scripts/
    ├── theme-switcher.sh   # Super+Shift+T → cycle themes
    └── wallpaper-fetch.sh  # Super+Alt+W → fetch Unsplash wallpaper
```

```
private_dot_config/sddm/
├── sddm-hyprland/          # HyDE sddm theme (cloned at apply time)
└── (applied by run_once script)
```

---

## Keybindings

**Vim-style overrides (not HyDE defaults):**

```hypr
# Focus
bind = $mainMod, h, movefocus, l
bind = $mainMod, l, movefocus, r
bind = $mainMod, k, movefocus, u
bind = $mainMod, j, movefocus, d

# Move window
bind = $mainMod SHIFT, h, movewindow, l
bind = $mainMod SHIFT, l, movewindow, r
bind = $mainMod SHIFT, k, movewindow, u
bind = $mainMod SHIFT, j, movewindow, d
```

**Other binds:**

| Action | Binding |
|---|---|
| App launcher (wofi) | `Super + Space` |
| Power menu (wlogout) | `Super + Shift + Q` |
| Theme switcher | `Super + Shift + T` |
| Wallpaper fetch | `Super + Alt + W` |
| Lock screen (hyprlock) | `Super + Shift + L` |
| Reload config | `Super + Shift + R` |
| Terminal | `Super + Return` |
| Scratchpad | `Super + S` |

---

## Scripts

### `run_once_080-hyprland-deps.sh.tmpl`
Installs all Hyprland ecosystem dependencies per flavor. Guards on `{{ if ne .de "hyprland" }}exit 0{{ end }}`.

### `run_once_080-hyprland-sddm.sh.tmpl`
Clones HyDE sddm-hyprland, installs SDDM, enables via systemctl. Guards on `.de == "hyprland"` and `.flavor != "darwin"`.

### `scripts/theme-switcher.sh`
Reads `~/.config/hypr/themes/` directory, cycles which theme file is `source=`d in `hyprland.conf`. Initially ships with only mocha.conf — future-proof for adding frappe/latte/macchiato.

### `scripts/wallpaper-fetch.sh`
Calls Unsplash API via `hyprpaper-unsplash` (or raw curl), saves wallpaper to `~/.wallpaper`, updates `swww` config. Requires `unsplashApiKey` secret.

---

## Secrets

| Key | Used by | Notes |
|---|---|---|
| `unsplashApiKey` | `wallpaper-fetch.sh` | Free tier at unsplash.com/developers |

Stored in `~/.config/chezmoi/chezmoi.toml` (never committed). Template reference: `{{ .unsplashApiKey }}`.

---

## Theming

**Catppuccin Mocha** as the single theme:
- All colors defined in `themes/mocha.conf` as Hyprland variables (`$mauve`, `$flamingo`, `$surface0`, etc.)
- Applied consistently to: Hyprland borders/shadows, waybar, wofi
- Cursor: `catppuccin-mocha-dark-cursors` (set via `exec-once = hyprctl setcursor`)

**Wofi styling** (`wofi/config`):
- Catppuccin Mocha palette background/foreground
- Rounded corners (border_radius ~8px)
- Matching font (JetBrains Mono or system default)

---

## Login Screen

**SDDM** with [HyDE sddm-hyprland](https://github.com/HyDE-Project/sddm-hyprland):
- Layer-shell based greeter, consistent with Hyprland aesthetics
- Current wallpaper synced to SDDM background
- Catppuccin Mocha theme applied

Applied by `run_once_080-hyprland-sddm.sh.tmpl` which:
1. Clones `HyDE-Project/sddm-hyprland`
2. Copies theme to SDDM directory
3. Runs `systemctl enable sddm`

---

## Wallpaper Carousel

- **Daemon:** `swww` — smooth animated transitions, multi-monitor support
- **Fetcher:** `hyprpaper-unsplash` (AUR/COPR) or raw curl to Unsplash API
- **Trigger:** `Super+Alt+W` (manual) + auto-rotation timer (default 15 min)
- **Unsplash query:** `nature,dark,minimal` — gives Catppuccin-adjacent aesthetics
- **Fallback:** If no API key, uses local wallpaper in `~/.wallpaper`

---

## Status Bar (waybar)

Modules:
- workspaces (vim-numbered 1-10)
- window title
- clock
- cpu / memory
- pulseaudio (scroll to adjust volume)
- brightness (brightnessctl for laptop backlight, tooltip shows %)
- bluetooth (blueman indicator, auto-hides when off)
- battery (on laptops)

Catppuccin Mocha styling throughout.

---

## `.chezmoiignore`

Hyprland configs are guarded by:
```
{{ if ne .de "hyprland" }}
.config/hypr
.config/waybar
.config/rofi
.config/dunst
.config/hyprlock
{{ end }}
```

This blocks Hyprland-specific configs from being applied to GNOME, KDE, or headless machines.

---

## Sources

- [HyDE-Project/HyDE](https://github.com/HyDE-Project/HyDE) — modular config structure
- [HyDE-Project/sddm-hyprland](https://github.com/HyDE-Project/sddm-hyprland) — SDDM greeter
- [hyprwallhaven](https://github.com/AnatolyRugalev/hyprwallhaven) — Wallhaven CLI (alternative to Unsplash)
- [hyprpaper-unsplash](https://github.com/qwertzui11/hyprpaper-wallpaper-fetcher) — Unsplash wallpaper fetcher
- [SwayOSD](https://github.com/ErikReider/SwayOSD) — volume/brightness OSD
- [wob](https://github.com/francma/wob) — lightweight OSD overlay
