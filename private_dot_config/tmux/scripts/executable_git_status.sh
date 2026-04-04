#!/bin/bash
# ============================================
# Git Status Module for Tmux
# Shows: branch name, worktree indicator, dirty/sync status
# Output format:  branch-name● with proper styling
# ============================================

# Get current pane's working directory
PANE_PATH="$1"
if [ -z "$PANE_PATH" ]; then
    PANE_PATH="$(pwd)"
fi

cd "$PANE_PATH" 2>/dev/null || exit 0

# Check if git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    exit 0
fi

# Get branch name
BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

# Check if worktree
WORKTREE_ROOT=$(git worktree list --porcelain 2>/dev/null | head -3 | grep "worktree" | cut -d' ' -f2-)
MAIN_WORKTREE=$(git worktree list --porcelain 2>/dev/null | grep -A2 "bare" | grep "worktree" | head -1 | cut -d' ' -f2-)

WORKTREE_INDICATOR=""
if [ "$WORKTREE_ROOT" != "$MAIN_WORKTREE" ] && [ -n "$MAIN_WORKTREE" ]; then
    WORKTREE_NAME=$(basename "$WORKTREE_ROOT")
    WORKTREE_INDICATOR="@${WORKTREE_NAME}"
fi

# Check dirty status
DIRTY=""
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    DIRTY="●"
fi

# Check ahead/behind status
AHEAD_BEHIND=""
UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)
if [ -n "$UPSTREAM" ]; then
    # Get ahead/behind counts
    AHEAD=$(git rev-list --count "@{u}..HEAD" 2>/dev/null || echo "0")
    BEHIND=$(git rev-list --count "HEAD..@{u}" 2>/dev/null || echo "0")
    
    if [ "$AHEAD" -gt 0 ] && [ "$BEHIND" -gt 0 ]; then
        AHEAD_BEHIND="⇅"
    elif [ "$AHEAD" -gt 0 ]; then
        AHEAD_BEHIND="↑"
    elif [ "$BEHIND" -gt 0 ]; then
        AHEAD_BEHIND="↓"
    fi
fi

# Combine status indicators
STATUS="${DIRTY}${AHEAD_BEHIND}"

# Output with proper format for catppuccin integration
if [ -n "$WORKTREE_INDICATOR" ]; then
    echo "#[bg=#a6e3a1,fg=#1e1e2e]  ${BRANCH}${WORKTREE_INDICATOR}${STATUS} #[fg=#a6e3a1,bg=default]"
else
    echo "#[bg=#a6e3a1,fg=#1e1e2e]  ${BRANCH}${STATUS} #[fg=#a6e3a1,bg=default]"
fi
