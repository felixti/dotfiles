# dotfiles

Reproducible machine setup managed by [chezmoi](https://chezmoi.io).

## Bootstrap a new machine

```bash
# 1. Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"

# 2. Init and apply (wizard prompts for flavor, DE, identity, API keys)
chezmoi init --apply gh:felixti/dotfiles
```

The wizard asks for:
- **Distro flavor** — `fedora-atomic` | `arch` | `debian` | `macos`
- **Desktop environment** — `gnome` | `kde` | `hyprland` | `none`
- **Git name + email**
- **API keys** (blank to skip any)

Your secrets are stored in `~/.config/chezmoi/chezmoi.toml` — never committed.

## Flavors and DEs supported

| Flavor | Distros |
|---|---|
| `fedora-atomic` | Bluefin, Aurora |
| `arch` | Arch Linux, CachyOS |
| `debian` | Ubuntu, Debian, Pop!_OS |
| `macos` | macOS |

| DE | Notes |
|---|---|
| `gnome` | Bluefin, Ubuntu, Arch+GNOME |
| `kde` | Aurora, CachyOS KDE |
| `hyprland` | Arch+Hyprland, CachyOS+Hyprland |
| `none` | Headless / server |

## Day-to-day commands

```bash
chezmoi cd              # open shell in source dir
chezmoi diff            # preview pending changes
chezmoi apply           # apply source → $HOME
chezmoi update          # git pull + apply (other machines)
chezmoi add FILE        # start tracking a new file
chezmoi edit FILE       # edit tracked file
chezmoi doctor          # diagnose issues
```

## Adding a new secret

1. Add key to `secrets.example.toml` (commit this)
2. Add key + value to `~/.config/chezmoi/chezmoi.toml` (never commit)
3. Reference in a template: `{{ .newApiKey }}`
4. `chezmoi apply`

## Structure overview

```
dot_config/zsh/          # zsh (aliases, env, functions, tools)
dot_config/tmux/         # tmux + catppuccin theme
dot_config/nvim/         # AstroNvim
dot_config/ghostty/      # Ghostty terminal
dot_config/kitty/        # Kitty terminal
dot_config/starship/     # Starship prompt themes
dot_config/yazi/         # Yazi file manager
dot_config/television/   # television fuzzy TUI
dot_config/btop/         # btop
dot_config/glow/         # glow markdown reader
dot_config/thefuck/      # thefuck
dot_config/gh/           # GitHub CLI

# DE-specific (guarded by .chezmoiignore)
dot_config/pop-shell/    # GNOME tiling
dot_config/gtk-*/        # GNOME themes
dot_config/hypr/         # Hyprland
```

## What's NOT tracked

- `~/.config/gh/hosts.yml` — GitHub tokens
- `~/.ssh/` — SSH keys
- `~/.claude.json` — session metadata (rendered from template at apply time)
- `~/.zsh_history` — personal shell history
