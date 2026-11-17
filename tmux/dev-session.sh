#!/bin/bash
# Windows: 1 nvim, 2 zsh (2x2), 3 llms (2x2 codex/claude), 4 99 (Codex worker for nvim's 99 plugin)
SESSION_NAME="$(basename "$PWD" | tr '.' '-')"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    tmux attach-session -t "$SESSION_NAME"
else
    tmux new-session -d -s "$SESSION_NAME" -c "$PWD"
    tmux send-keys -t "$SESSION_NAME":1 'nvim .' Enter
    ZSH_PANE=$(tmux new-window -t "$SESSION_NAME" -n zsh -c "$PWD" -P -F '#{pane_id}')
    ZSH_WIN=$(tmux display-message -p -t "$ZSH_PANE" '#{window_id}')
    tmux split-window -h -t "$ZSH_WIN" -c "$PWD"
    tmux split-window -h -t "$ZSH_WIN" -c "$PWD"
    tmux split-window -h -t "$ZSH_WIN" -c "$PWD"
    tmux select-layout -t "$ZSH_WIN" tiled
    tmux select-pane -t "$ZSH_PANE"
    "$SCRIPT_DIR/ab-agents.sh" "$SESSION_NAME"
    WORKER_PANE=$(tmux new-window -t "$SESSION_NAME" -n 99 -c "$PWD" -P -F '#{pane_id}' "$SCRIPT_DIR/codex-99-worker.sh")
    tmux set-option -p -t "$WORKER_PANE" @codex_99_worker 1
    tmux select-window -t "$SESSION_NAME":1
    tmux attach-session -t "$SESSION_NAME"
fi
