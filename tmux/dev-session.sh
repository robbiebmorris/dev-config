#!/bin/bash

SESSION_NAME="dev-$(basename "$PWD" | tr '.' '-')"

if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    tmux attach-session -t "$SESSION_NAME"
else
    tmux new-session -d -s "$SESSION_NAME" -c "$PWD"
    tmux send-keys -t "$SESSION_NAME":1 'nvim .' Enter
    tmux new-window -t "$SESSION_NAME" -n zsh -c "$PWD"
    tmux select-window -t "$SESSION_NAME":1
    tmux attach-session -t "$SESSION_NAME"
fi

