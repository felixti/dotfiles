# Hyprland File Manager: Nemo + Yazi Choice

Date: 2026-04-04
Status: approved

---

## Overview

Add file manager choice to the Hyprland setup — Nemo (GUI, Catppuccin Mocha) or Yazi (TUI, already configured). Choice is made at bootstrap via chezmoi wizard.

---

## Changes

### 1. Bootstrap wizard — `.chezmoi.toml.tmpl`

Add `fileManager` prompt:
```
{{- $fileManager := promptStringOnce . "fileManager" "File manager (yazi/nemo)" -}}
```
Saved as `fileManager = {{ $fileManager | quote }}` in `[data]`.

### 2. Hyprland deps installer — `run_once_080-hyprland-deps.sh.tmpl`

Add Nemo install per distro (inside existing arch/debian/fedora blocks):
- **Arch**: `pacman -S nemo nemo-preview nemo-fileroller` via `paru`
- **Debian**: `apt install -y nemo nemo-preview fileroller`
- **Fedora**: `dnf install -y nemo nemo-preview` (from COPR or system repo)

### 3. Hyprland environment.conf — `environment.conf`

Set `$fileManager` dynamically:
```hypr
$fileManager = {{ if eq .fileManager "nemo" }}nemo{{ else }}yazi --cwd $HOME{{ end }}
```

### 4. Keybindings.conf

Bind `Super+E` to launch `$fileManager`:
```hypr
bind = $mainMod, E, exec, $fileManager
```

### 5. GTK CSS for Nemo — `private_dot_config/gtk-3.0/gtk.css`

Add Nemo sidebar Catppuccin Mocha overrides:
```css
/* Nemo sidebar Catppuccin Mocha */
.nemo-window .sidebar { background-color: #1e1e2e; color: #cdd6f4; }
.nemo-window .sidebar .nemo-window-row { color: #cdd6f4; }
.nemo-window .sidebar .nemo-window-row:selected { background-color: #313244; color: #cba6f7; }
.nemo-window .nemoPlacesSidebar { background-color: #1e1e2e; }
.nemo-window .nemo-inactive-pane .view { background-color: #1e1e2e; }
.nemo-window .nemo-window-pane > .view { background-color: #181825; }
```

### 6. Secrets

No new secrets needed.

---

## Yazi config

Existing Yazi config in `dot_config/yazi/` is unchanged — works as fallback when `fileManager = "yazi"`.

---

## Sources

- [Nemo GTK Theming · Issue #2563 · linuxmint/nemo](https://github.com/linuxmint/nemo/issues/2563)
- [Catppuccin GTK Theme Mocha — AUR](https://aur.archlinux.org/packages/catppuccin-gtk-theme-mocha)
