#!/bin/bash
# ab-agents.sh — 2x2 grid of agents: Codex | Codex on top, Claude | Claude below.
#
# Usage:
#   ab-agents.sh            # inside tmux: split the current window into the grid
#   ab-agents.sh SESSION    # add an "llms" window to SESSION (used by dev-session.sh)
set -euo pipefail

SESSION="${1:-}"

if [[ -n "$SESSION" ]]; then
    TL=$(tmux new-window -t "$SESSION" -n llms -c "$PWD" -P -F '#{pane_id}' codex)
elif [[ -n "${TMUX:-}" ]]; then
    TL=$(tmux display-message -p '#{pane_id}')
    tmux send-keys -t "$TL" codex Enter
else
    echo "Run inside tmux, or pass a session name." >&2
    exit 1
fi

# One horizontal split, then split each half vertically -> always 4 panes.
TR=$(tmux split-window -h -t "$TL" -c "$PWD" -P -F '#{pane_id}' codex)
tmux split-window -v -t "$TL" -c "$PWD" claude
tmux split-window -v -t "$TR" -c "$PWD" claude
tmux select-pane -t "$TL"
