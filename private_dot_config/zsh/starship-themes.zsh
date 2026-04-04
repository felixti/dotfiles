#!/usr/bin/env zsh
# ============================================
# STARSHIP THEME SWITCHER
# Usage: starship-theme [minimal|developer|cyber]
# ============================================

STARSHIP_DIR="$HOME/.config/starship"

theme_minimal() {
    cp "${STARSHIP_DIR}/minimal.toml" "$HOME/.config/starship.toml"
    echo "✓ Switched to Minimal Zen theme"
}

theme_developer() {
    cp "${STARSHIP_DIR}/developer.toml" "$HOME/.config/starship.toml"
    echo "✓ Switched to Developer Pro theme"
}

theme_cyber() {
    cp "${STARSHIP_DIR}/cyber.toml" "$HOME/.config/starship.toml"
    echo "✓ Switched to Cyber Modern theme"
}

starship-theme() {
    case "$1" in
        minimal|zen|clean)
            theme_minimal
            ;;
        developer|dev|pro|rich)
            theme_developer
            ;;
        cyber|neon|modern|powerline)
            theme_cyber
            ;;
        ls|list)
            echo "Available themes:"
            echo "  minimal    - Ultra clean, distraction-free"
            echo "  developer  - Rich info with tech badges"
            echo "  cyber      - Neon powerline, futuristic"
            ;;
        *)
            echo "Usage: starship-theme [minimal|developer|cyber]"
            echo "       starship-theme ls (to list themes)"
            return 1
            ;;
    esac
}

# Quick aliases
alias theme-zen='starship-theme minimal'
alias theme-dev='starship-theme developer'
alias theme-cyber='starship-theme cyber'

# Initialize with developer theme by default if no starship.toml exists
if [ ! -f "$HOME/.config/starship.toml" ]; then
    theme_developer 2>/dev/null || true
fi
