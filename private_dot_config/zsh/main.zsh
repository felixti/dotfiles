# ============================================
# POWERHOUSE ZSH CONFIGURATION
# ============================================
# Main loader - sources all modular configurations
#
# To use: Add this line to your ~/.zshrc:
#   source ~/.config/zsh/main.zsh
# ============================================

ZSH_CONFIG_DIR="${0:A:h}"

# Source all configuration files
source "${ZSH_CONFIG_DIR}/env.zsh"
source "${ZSH_CONFIG_DIR}/aliases.zsh"
source "${ZSH_CONFIG_DIR}/functions.zsh"
source "${ZSH_CONFIG_DIR}/starship-themes.zsh"
source "${ZSH_CONFIG_DIR}/tmux-helpers.zsh"
source "${ZSH_CONFIG_DIR}/tools.zsh"  # Must be last (initializes prompt)

# Clean up
unset ZSH_CONFIG_DIR
