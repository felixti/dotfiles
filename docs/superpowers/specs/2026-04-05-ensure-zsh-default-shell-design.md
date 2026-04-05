# Design: Ensure Zsh Is Installed and Set as Default Shell

**Date:** 2026-04-05
**Status:** Approved
**Scope:** New chezmoi script `run_once_005-ensure-zsh.sh.tmpl`

## Problem

The dotfiles repo deploys a full zsh configuration (`dot_zshrc.tmpl`, `~/.config/zsh/`, antidote plugins), but no chezmoi script ensures zsh is actually installed or set as the login shell. This breaks bootstrap on platforms where zsh is not present by default (notably Debian/Ubuntu).

## Solution

A new `run_once_005-ensure-zsh.sh.tmpl` script that:

1. Ensures zsh is installed (using native package managers)
2. Sets zsh as the user's default login shell

### Script Numbering

`005` — runs after system update (000) and before Homebrew (010). This guarantees zsh is available before any zsh-dependent config gets sourced.

### Platform Matrix

| Flavor | Install Method | Set Default Shell |
|---|---|---|
| `fedora-atomic` | Skip (zsh is in the base image) | `sudo usermod -s /usr/bin/zsh "$USER"` |
| `arch` | `sudo pacman -S --noconfirm zsh` | `chsh -s /usr/bin/zsh` |
| `debian` | `sudo apt install -y zsh` | `chsh -s $(command -v zsh)` |
| `macos` | Skip (ships with zsh, default since Catalina) | Exit immediately |

### Why `usermod` on Fedora Atomic

`chsh` is deliberately removed from Fedora Atomic images (setuid security concern). The `util-linux-user` subpackage that provides it is not layered and layering it is discouraged.

`sudo usermod -s` from `shadow-utils` (already present) is the working, non-interactive, scriptable alternative. `/etc` lives on a writable btrfs subvolume, so the `/etc/passwd` modification persists across reboots and OS upgrades.

**Important:** Always use the system path `/usr/bin/zsh`, never a Homebrew path. If Homebrew becomes unavailable, a Homebrew shell path in `/etc/passwd` would cause a login failure.

### Script Flow

```
1. macOS guard — exit 0 (zsh is already the default shell)
2. Install zsh if not in $PATH:
   - fedora-atomic: skip (already in base image; warn and exit if missing,
     since rpm-ostree install is not idempotent in a run_once script)
   - arch: sudo pacman -S --noconfirm zsh
   - debian: sudo apt install -y zsh
3. Verify zsh binary exists (command -v zsh), fail if not
4. Check current login shell: getent passwd "$USER" | cut -d: -f7
   - If already zsh, print confirmation and exit
5. Set default shell:
   - fedora-atomic: sudo usermod -s /usr/bin/zsh "$USER"
   - arch/debian: chsh -s $(command -v zsh)
6. Print reminder: "Log out and back in for the shell change to take effect"
```

### Edge Cases

- **Fedora Atomic with zsh somehow missing:** The script warns and exits non-zero rather than attempting `rpm-ostree install` (which requires a reboot and doesn't fit `run_once` semantics).
- **`chsh` password prompt on arch/debian:** Expected and unavoidable for the current user. Interactive prompting is acceptable during bootstrap.
- **`/etc/shells` missing zsh:** On arch/debian, `chsh` validates against `/etc/shells`. The script checks and appends the zsh path if absent (requires sudo).
- **Re-runs:** `run_once` means chezmoi runs this exactly once. If the user changes their shell back to bash later, they'd need `chezmoi state delete-bucket --bucket=scriptState` to re-trigger.

### What This Does NOT Do

- Install zsh via Homebrew (uses native OS packages intentionally)
- Modify any zsh configuration (handled by `dot_zshrc.tmpl` and `~/.config/zsh/`)
- Install zsh plugins (handled by antidote via `.chezmoiexternal.toml`)
- Configure terminal emulator profiles (out of scope)

## Files Changed

| File | Action |
|---|---|
| `.chezmoiscripts/run_once_005-ensure-zsh.sh.tmpl` | **New** — the script described above |
| `CLAUDE.md` | Update script numbering table to include 005 |

## Testing

```bash
chezmoi diff                    # Preview changes
chezmoi apply -n                # Dry run
chezmoi apply                   # Apply (runs the script)
getent passwd "$USER" | cut -d: -f7   # Verify shell changed
echo $SHELL                     # Verify (after re-login)
```
