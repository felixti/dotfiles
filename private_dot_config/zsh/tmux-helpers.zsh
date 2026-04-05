#!/usr/bin/env zsh
# ============================================
# TMUX HELPER FUNCTIONS
# ============================================

# Install tmux plugins (run this after first setup)
tmux-install-plugins() {
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        echo "Installing TPM..."
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi
    
    echo "Installing plugins..."
    ~/.tmux/plugins/tpm/bin/install_plugins
    echo "✓ Plugins installed. Restart tmux or press 'Prefix + I' to install."
}

# Update all tmux plugins
tmux-update-plugins() {
    echo "Updating plugins..."
    ~/.tmux/plugins/tpm/bin/update_plugins all
    echo "✓ Plugins updated"
}

# Clean removed plugins
tmux-clean-plugins() {
    echo "Cleaning removed plugins..."
    ~/.tmux/plugins/tpm/bin/clean_plugins
    echo "✓ Plugins cleaned"
}

# Quick tmux aliases
alias t='tmux'
alias ta='tmux attach'
alias tad='tmux attach -d'  # Detach others
alias tas='tmux attach-session -t'
alias tls='tmux list-sessions'
alias tks='tmux kill-server'
alias tkw='tmux kill-window'
alias tns='tmux new-session -s'

# Fuzzy session switcher
tswitch() {
    local session
    session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&
    tmux switch-client -t "$session"
}
alias tsw='tswitch'

# Create or attach to named session
tmux-dev() {
    local name="${1:-dev}"
    tmux new-session -A -s "$name"
}
alias td='tmux-dev'

# Show tmux keybindings cheat sheet
tmux-help() {
    cat << 'EOF'
TMUX KEYBINDINGS (Prefix: Ctrl+S)
==================================
Sessions:
  Ctrl+S $  Rename session
  Ctrl+S D  Detach
  Ctrl+S S  List sessions
  Ctrl+S C-c  New session
  
Windows:
  Ctrl+S C  Create window
  Ctrl+S ,  Rename window
  Ctrl+S &  Kill window
  Ctrl+S N  Next window
  Ctrl+S P  Previous window
  Ctrl+S 0-9  Switch to window
  Ctrl+S Tab  Last window
  Ctrl+S <  Move window left
  Ctrl+S >  Move window right
  
Panes:
  Ctrl+S |  Split horizontal
  Ctrl+S -  Split vertical
  Ctrl+S Z  Zoom pane
  Ctrl+S X  Kill pane
  Ctrl+H/J/K/L  Navigate panes (vim style)
  Ctrl+H/J/K/L (hold) Resize pane
  
Special:
  Ctrl+S R  Reload config
  Ctrl+S G  Open lazygit popup
  Ctrl+S F  Open yazi file manager popup
  Ctrl+S S  Sync panes (toggle)
  Ctrl+S B  Toggle status bar
  Ctrl+S ?  Show all keybindings
  
TPM (Plugin Manager):
  Ctrl+S I    Install plugins
  Ctrl+S U    Update plugins
  Ctrl+S Alt+U  Remove unused plugins

PLUGINS INSTALLED:
  - catppuccin (theme)
  - tmux-resurrect (save/restore sessions)
  - tmux-continuum (auto-save)
  - vim-tmux-navigator (vim integration)
  - tmux-yank (clipboard)
EOF
}

# ============================================
# TMUX AUTO-ATTACH (for SSH/local)
# ============================================

# Auto-attach to main session or create new one
# Uncomment to enable for local terminals too
# if [ -z "$TMUX" ] && [ -z "$SSH_CONNECTION" ]; then
#     tmux attach -t main 2>/dev/null || tmux new -s main
# fi

# Auto-attach for SSH sessions
if [ -z "$TMUX" ] && [ -n "$SSH_CONNECTION" ]; then
    tmux attach -t main 2>/dev/null || tmux new -s main
fi
