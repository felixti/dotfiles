# Chezmoi Bootstrap Improvements Design

**Date:** 2025-04-05  
**Status:** Approved  
**Scope:** Fix critical dependency issues and simplify chezmoi bootstrap scripts

---

## Problem Statement

The current chezmoi bootstrap has several critical sequencing and dependency issues:

1. **Script 030 (cargo tools) runs before 040 (runtimes)** - yazi needs cargo, but rustup isn't installed yet
2. **Script 020 assumes brew is in PATH** - after 010 installs it, but shellenv may not be loaded
3. **Script 061 installs too many flatpaks** - vscodium, firefox, discord auto-install without user choice
4. **~/.bin directory not created** - needed for bin/update.tmpl
5. **No retry logic** - network failures on critical downloads require manual re-run

---

## Design Decisions

### Decision 1: Move Yazi to Homebrew, Delete Script 030

**Rationale:**
- Yazi is available in Homebrew (`brew install yazi`)
- Eliminates 030/040 dependency chain issue entirely
- Faster install (bottled binary vs compile from source)
- Reduces script count and complexity

**Implementation:**
- Delete `run_once_030-install-cargo-tools.sh`
- Add `yazi` to TOOLS array in script 020

**Trade-offs:**
- (+) Simpler dependency graph
- (+) Faster bootstrap
- (-) One less cargo tool (but yazi is the only one, so no loss)

---

### Decision 2: Ensure Brew PATH in Script 020

**Rationale:**
- After 010 installs Homebrew, the shellenv isn't automatically available
- Script 020 runs in same shell session, needs explicit evaluation

**Implementation:**
Add to top of script 020:
```bash
# Ensure brew is available (installed in 010)
if ! command -v brew &>/dev/null; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv 2>/dev/null || /opt/homebrew/bin/brew shellenv)"
fi
```

---

### Decision 3: Flatpak Support + Spotify Only

**Rationale:**
- Install flatpak package only if missing (distro-appropriate)
- Configure flathub remote with `--user` flag
- Install only Spotify (user explicitly requested)
- Skip other apps (vscodium, firefox, discord) - user can install manually

**Per-distro behavior:**

| Flavor | Flatpak Package Action |
|--------|----------------------|
| fedora-atomic | Skip (pre-installed) |
| fedora | Skip (pre-installed) |
| arch | `sudo pacman -S --noconfirm flatpak` |
| debian | `sudo apt install -y flatpak` |

**Post-install:**
```bash
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install --user -y flathub com.spotify.Client
```

---

### Decision 4: Create ~/.bin in Script 005

**Rationale:**
- Script 000 used to create this but no longer does
- bin/update.tmpl needs to land in ~/.bin
- Single directory creation is minimal overhead

**Implementation:**
Add to script 005 after zsh install:
```bash
mkdir -p "$HOME/.bin"
```

---

### Decision 5: Retry Logic for Critical Downloads

**Rationale:**
- Network failures on Homebrew, nvm, or bun are painful on fresh installs
- Simple 3-attempt retry with 2-second sleep is low complexity
- Only add to critical paths, not all scripts

**Implementation:**
Create helper function in affected scripts:
```bash
download_with_retry() {
    local cmd="$1"
    for i in {1..3}; do
        if eval "$cmd"; then
            return 0
        fi
        echo "Attempt $i failed, retrying..."
        sleep 2
    done
    echo "ERROR: All attempts failed"
    return 1
}
```

Apply to:
- Script 010: Homebrew install
- Script 040: nvm install, bun install

---

## File Changes Summary

| File | Action | Details |
|------|--------|---------|
| `.chezmoiscripts/run_once_030-install-cargo-tools.sh` | **DELETE** | Entire file removed |
| `.chezmoiscripts/run_once_020-install-cli-tools.sh.tmpl` | MODIFY | Add yazi to TOOLS, add brew PATH check |
| `.chezmoiscripts/run_once_061-fedora-flatpaks.sh.tmpl` | MODIFY | Simplify to flatpak support + spotify only |
| `.chezmoiscripts/run_once_005-ensure-zsh.sh.tmpl` | MODIFY | Add `mkdir -p ~/.bin` |
| `.chezmoiscripts/run_once_010-install-homebrew.sh.tmpl` | MODIFY | Add retry logic |
| `.chezmoiscripts/run_once_040-install-runtimes.sh` | MODIFY | Add retry logic for nvm, bun |

---

## Verification Steps

After implementation, verify:

1. **Fresh Ubuntu VM:**
   - Run `chezmoi init --apply`
   - Confirm yazi installs via brew (not cargo)
   - Confirm 030 script doesn't exist/run

2. **Brew availability:**
   - Check that script 020 finds brew without errors
   - Verify all CLI tools install

3. **Flatpak:**
   - Confirm flatpak installs only on arch/debian
   - Confirm spotify installs via flatpak
   - Confirm vscodium/firefox/discord do NOT auto-install

4. **~/.bin:**
   - Directory exists after 005 runs
   - update script lands in ~/.bin

---

## Rollback Plan

If issues occur:
- Restore script 030 from git history
- Remove yazi from brew TOOLS array
- Revert flatpak script to previous version

---

## Future Considerations

- Consider consolidating all "package installer" logic into per-distro helper scripts
- Evaluate if more tools could move from cargo/build to brew
- Consider adding `set -x` debug mode flag for troubleshooting
