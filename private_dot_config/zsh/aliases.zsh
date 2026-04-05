# ============================================
# MODERN TOOL ALIASES
# ============================================

# eza (modern ls replacement)
alias ls='eza --icons --group-directories-first'
alias ll='eza -lah --icons --git --group-directories-first'
alias la='eza -A --icons --group-directories-first'
alias l='eza -F --icons --group-directories-first'
alias lt='eza --tree --icons --level=2'
alias llt='eza -lah --tree --icons --git --level=2'

# bat (modern cat with syntax highlighting)
alias cat='bat --paging=never --style=plain'
alias batcat='bat'
alias catl='bat --language'

# fd (modern find replacement) - careful override
alias find='fd'
alias fdi='fd -i'
alias fde='fd -e'
alias fdh='fd --hidden'

# ripgrep (modern grep)
alias grep='rg'
alias rg='rg --smart-case'
alias rgi='rg -i'
alias rgf='rg --files-with-matches'
alias rgh='rg --smart-case --hidden'
alias rga='rg --smart-case --follow --hidden'

# zoxide (smart cd replacement)
alias cd='z'
alias cdi='zi'
alias ..='z ..'
alias ...='z ../..'

# television (fuzzy finder TUI) - using actual 'tv' command from brew
# Note: 'tv' is the actual binary name, no alias needed
alias tvg='tv grep'
alias tvf='tv files'

# lazygit
alias lg='lazygit'

# ============================================
# DOCKER ALIASES
# ============================================
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dcu='docker-compose up -d'
alias dcd='docker-compose down'
alias dcl='docker-compose logs -f'
alias dcb='docker-compose build'

# ============================================
# TAILSCALE ALIASES
# ============================================
alias ts='tailscale'
alias tss='tailscale status'
alias tsip='tailscale ip'

# ============================================
# DIRECTORY SHORTCUTS (with zoxide)
# ============================================
alias proj='z ~/powerhouse/projects'
alias srv='z ~/powerhouse/services'

# ============================================
# FILE MANAGER
# ============================================
alias fm='yy'  # yazi with cd-on-quit
alias zz='_zoxide_hook_and_ls'  # z + auto-ls

# ============================================
# SYSTEM UPDATE
# ============================================
alias update='~/.local/bin/update'
