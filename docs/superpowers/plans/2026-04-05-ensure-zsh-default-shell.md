# Ensure Zsh Default Shell — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a chezmoi bootstrap script that ensures zsh is installed and set as the user's default login shell across all supported platforms.

**Architecture:** Single `run_once_005` chezmoi script using Go templates for platform branching. Uses native package managers to install zsh and platform-appropriate commands (`usermod` on Fedora Atomic, `chsh` elsewhere) to set the login shell.

**Tech Stack:** Bash, chezmoi Go templates, native package managers (pacman, apt), shadow-utils (usermod), chsh

---

## File Map

| File | Action | Responsibility |
|---|---|---|
| `.chezmoiscripts/run_once_005-ensure-zsh.sh.tmpl` | **Create** | Install zsh + set as default shell |
| `CLAUDE.md` | **Modify (line 41)** | Add `005` to script numbering table |

---

### Task 1: Create the `run_once_005-ensure-zsh.sh.tmpl` script

**Files:**
- Create: `.chezmoiscripts/run_once_005-ensure-zsh.sh.tmpl`

- [ ] **Step 1: Create the script**

Write to `.chezmoiscripts/run_once_005-ensure-zsh.sh.tmpl`:

```bash
#!/usr/bin/env bash
{{ if eq .chezmoi.os "darwin" }}exit 0{{ end }}
# Ensure zsh is installed and set as the default login shell
set -euo pipefail

# --- Install zsh if not present ---
if ! command -v zsh &>/dev/null; then
{{ if eq .flavor "fedora-atomic" }}
    echo "ERROR: zsh is not installed and cannot be added via rpm-ostree in a run_once script."
    echo "       Layer it manually: rpm-ostree install zsh && systemctl reboot"
    exit 1
{{ else if eq .flavor "arch" }}
    echo "Installing zsh..."
    sudo pacman -S --noconfirm zsh
{{ else if eq .flavor "debian" }}
    echo "Installing zsh..."
    sudo apt install -y zsh
{{ else }}
    echo "ERROR: unsupported flavor for zsh install"
    exit 1
{{ end }}
fi

ZSH_PATH="$(command -v zsh)"
echo "zsh found at $ZSH_PATH"

# --- Ensure zsh is in /etc/shells ---
if ! grep -qx "$ZSH_PATH" /etc/shells 2>/dev/null; then
    echo "Adding $ZSH_PATH to /etc/shells..."
    echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
fi

# --- Check current login shell ---
CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"
if [ "$CURRENT_SHELL" = "$ZSH_PATH" ]; then
    echo "✓ zsh is already the default shell"
    exit 0
fi

# --- Set zsh as default shell ---
echo "Changing default shell from $CURRENT_SHELL to $ZSH_PATH..."
{{ if eq .flavor "fedora-atomic" }}
sudo usermod -s "$ZSH_PATH" "$USER"
{{ else }}
chsh -s "$ZSH_PATH"
{{ end }}

echo "✓ Default shell set to zsh"
echo "  Log out and back in for the change to take effect"
```

- [ ] **Step 2: Verify template syntax**

Run:
```bash
cd ~/dotfiles && chezmoi execute-template < .chezmoiscripts/run_once_005-ensure-zsh.sh.tmpl
```

Expected: Rendered bash script with the correct platform branch for your current `flavor` (`fedora-atomic`). No Go template syntax errors. The `darwin` guard should NOT trigger (you're on Linux), so you should see the full script body.

- [ ] **Step 3: Dry-run chezmoi apply**

Run:
```bash
chezmoi apply -n -v 2>&1 | grep -A5 "005-ensure-zsh"
```

Expected: chezmoi shows the script would be executed. No errors.

- [ ] **Step 4: Commit**

```bash
cd ~/dotfiles
git add .chezmoiscripts/run_once_005-ensure-zsh.sh.tmpl
git commit -m "feat: add run_once_005 to ensure zsh is installed and default shell

Covers all 4 flavors:
- fedora-atomic: skip install (base image), usermod -s
- arch: pacman install, chsh
- debian: apt install, chsh
- macos: exit early (zsh is default since Catalina)"
```

---

### Task 2: Update CLAUDE.md script numbering table

**Files:**
- Modify: `CLAUDE.md:40-50` (script numbering block)

- [ ] **Step 1: Add the 005 entry**

In `CLAUDE.md`, find the script numbering code block:

```
000  — system update (runs first)
010  — homebrew
```

Add a new line between them:

```
000  — system update (runs first)
005  — ensure zsh installed + default shell
010  — homebrew
```

- [ ] **Step 2: Commit**

```bash
cd ~/dotfiles
git add CLAUDE.md
git commit -m "docs: add 005 (ensure zsh) to script numbering table in CLAUDE.md"
```

---

### Task 3: Integration test on live system

- [ ] **Step 1: Verify current shell state**

Run:
```bash
getent passwd "$USER" | cut -d: -f7
```

Expected: `/usr/bin/zsh` (already set on your current system).

- [ ] **Step 2: Apply chezmoi**

Run:
```bash
chezmoi apply -v 2>&1 | grep -A5 "005-ensure-zsh"
```

Expected: Script runs, detects zsh is already the default, prints `✓ zsh is already the default shell`, and exits cleanly.

- [ ] **Step 3: Verify no side effects**

Run:
```bash
getent passwd "$USER" | cut -d: -f7
```

Expected: Still `/usr/bin/zsh` — no change since it was already correct.
