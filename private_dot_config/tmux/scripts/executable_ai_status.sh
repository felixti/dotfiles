#!/bin/bash
# ============================================
# AI Coding CLI Detector for Tmux
# Shows Nerd Font glyphs for AI tools
# Only shows AI tools running in THIS pane
# ============================================

PANE_PID="$1"
[ -z "$PANE_PID" ] && exit 0

# Get all process info in one call for efficiency
PANE_PROCS=$(ps -o pid=,comm=,cmd= -s $PANE_PID 2>/dev/null || ps -o pid=,comm=,cmd= --ppid $PANE_PID 2>/dev/null)
[ -z "$PANE_PROCS" ] && exit 0

# Check for AI tools
echo "$PANE_PROCS" | grep -qE "kimi" && { echo "#[bg=#cba6f7,fg=#1e1e2e] 󰽤 #[fg=#cba6f7,bg=default]"; exit 0; }
echo "$PANE_PROCS" | grep -qE "opencode" && { echo "#[bg=#cba6f7,fg=#1e1e2e] 󰅴 #[fg=#cba6f7,bg=default]"; exit 0; }
echo "$PANE_PROCS" | grep -qE "kilo-code|kilocode" && { echo "#[bg=#cba6f7,fg=#1e1e2e] 󰀘 #[fg=#cba6f7,bg=default]"; exit 0; }
echo "$PANE_PROCS" | grep -qE "copilot|gh-copilot" && { echo "#[bg=#cba6f7,fg=#1e1e2e]  #[fg=#cba6f7,bg=default]"; exit 0; }
echo "$PANE_PROCS" | grep -qE "claude" && { echo "#[bg=#cba6f7,fg=#1e1e2e] 󱙽 #[fg=#cba6f7,bg=default]"; exit 0; }
echo "$PANE_PROCS" | grep -qE "codex" && { echo "#[bg=#cba6f7,fg=#1e1e2e] 󱙺 #[fg=#cba6f7,bg=default]"; exit 0; }
echo "$PANE_PROCS" | grep -qE "aider" && { echo "#[bg=#cba6f7,fg=#1e1e2e] 󰭹 #[fg=#cba6f7,bg=default]"; exit 0; }
echo "$PANE_PROCS" | grep -qE "cursor" && { echo "#[bg=#cba6f7,fg=#1e1e2e] 󰆿 #[fg=#cba6f7,bg=default]"; exit 0; }
echo "$PANE_PROCS" | grep -qE "continue" && { echo "#[bg=#cba6f7,fg=#1e1e2e] 󰐒 #[fg=#cba6f7,bg=default]"; exit 0; }
echo "$PANE_PROCS" | grep -qE "codeium" && { echo "#[bg=#cba6f7,fg=#1e1e2e] 󰸶 #[fg=#cba6f7,bg=default]"; exit 0; }
