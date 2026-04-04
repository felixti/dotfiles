# ============================================
# CUSTOM FUNCTIONS
# ============================================

# yazi (terminal file manager) with cd-on-quit + zoxide integration
yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        z "$cwd"
    fi
    rm -f -- "$tmp"
}

# Auto-ls when using zoxide to jump
_zoxide_hook_and_ls() {
    z "$@" && eza --icons --group-directories-first
}

# ============================================
# FZF ADVANCED FUNCTIONS
# ============================================

# Interactive file search + edit
fe() {
    local files
    IFS=$'\n' files=($(fzf --query="$1" --multi --select-1 --exit-0 --preview 'bat --color=always --style=numbers --line-range=:500 {}'))
    [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

# Interactive ripgrep + fzf (search content then open)
fif() {
    if [ ! "$#" -gt 0 ]; then
        echo "Need a string to search for!"
        return 1
    fi
    rg --files-with-matches --no-messages "$1" | fzf --preview "rg --ignore-case --pretty --context 10 '$1' {}"
}

# Change directory with fzf + fd
fcd() {
    local dir
    dir=$(fd --type d --hidden --follow --exclude .git | fzf +m) &&
    z "$dir"
}

# Kill process with fzf
fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    if [ "x$pid" != "x" ]; then
        echo $pid | xargs kill -${1:-9}
    fi
}

# Git branch checkout with fzf
fbr() {
    local branches branch
    branches=$(git branch --all | grep -v HEAD) &&
    branch=$(echo "$branches" | fzf -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
    git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}
