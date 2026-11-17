#!/bin/bash
set -euo pipefail

PROMPT_FILE="${1:?prompt file is required}"
RESPONSE_FILE="${2:?response file is required}"
TIMEOUT_SECONDS="${CODEX_99_TIMEOUT_SECONDS:-900}"

if [[ -z "${TMUX:-}" ]]; then
    echo "99 Codex provider requires Neovim to be running inside tmux" >&2
    exit 2
fi

if [[ ! -r "$PROMPT_FILE" ]]; then
    echo "99 prompt file is not readable: $PROMPT_FILE" >&2
    exit 2
fi

SESSION=$(tmux display-message -p '#S')
PANE=$(
    tmux list-panes -s -t "$SESSION" \
        -F '#{pane_id} #{@codex_99_worker} #{pane_dead}' |
        awk '$2 == "1" && $3 == "0" { print $1; exit }'
)

if [[ -z "$PANE" ]]; then
    echo "No live 99 Codex worker pane found in tmux session: $SESSION" >&2
    exit 2
fi

SAFE_SESSION=$(printf '%s' "$SESSION" | tr -c '[:alnum:]_.-' '_')
LOCK_ROOT="${TMPDIR:-/tmp}/nvim-99/locks"
LOCK_DIR="$LOCK_ROOT/$SAFE_SESSION"
DEADLINE=$((SECONDS + TIMEOUT_SECONDS))
HAVE_LOCK=0
mkdir -p "$LOCK_ROOT"

cleanup() {
    if (( HAVE_LOCK == 1 )); then
        rm -f "$LOCK_DIR/pid"
        rmdir "$LOCK_DIR" 2>/dev/null || true
    fi
}

cancel() {
    tmux send-keys -t "$PANE" Escape 2>/dev/null || true
    exit 130
}

trap cancel INT TERM
trap cleanup EXIT

while ! mkdir "$LOCK_DIR" 2>/dev/null; do
    OWNER=""
    if [[ -r "$LOCK_DIR/pid" ]]; then
        OWNER=$(<"$LOCK_DIR/pid")
    fi
    if [[ -z "$OWNER" ]] || ! kill -0 "$OWNER" 2>/dev/null; then
        rm -f "$LOCK_DIR/pid"
        rmdir "$LOCK_DIR" 2>/dev/null || true
        continue
    fi
    if (( SECONDS >= DEADLINE )); then
        echo "Timed out waiting for the 99 Codex worker lock" >&2
        exit 124
    fi
    sleep 0.2
done
HAVE_LOCK=1
printf '%s\n' "$$" > "$LOCK_DIR/pid"

if [[ "$(tmux display-message -p -t "$PANE" '#{pane_in_mode}')" == "1" ]]; then
    tmux send-keys -t "$PANE" -X cancel
fi

BUFFER_NAME="codex-99-$$"
tmux load-buffer -b "$BUFFER_NAME" "$PROMPT_FILE"
tmux paste-buffer -p -b "$BUFFER_NAME" -t "$PANE" -d
# Codex ignores an Enter that arrives right after a paste; give the TUI a moment.
sleep 0.5
tmux send-keys -t "$PANE" Enter

LAST_SIZE=0
STABLE_CHECKS=0
while (( SECONDS < DEADLINE )); do
    SIZE=0
    if [[ -f "$RESPONSE_FILE" ]]; then
        SIZE=$(wc -c < "$RESPONSE_FILE" | tr -d '[:space:]')
    fi

    if (( SIZE > 0 )); then
        if (( SIZE == LAST_SIZE )); then
            STABLE_CHECKS=$((STABLE_CHECKS + 1))
        else
            STABLE_CHECKS=0
            LAST_SIZE=$SIZE
        fi
        if (( STABLE_CHECKS >= 2 )); then
            exit 0
        fi
    fi
    sleep 0.25
done

echo "Timed out waiting for Codex to write: $RESPONSE_FILE" >&2
exit 124
