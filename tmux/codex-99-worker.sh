#!/bin/bash
set -euo pipefail

TMP_ROOT="${TMPDIR:-/tmp}/nvim-99"
mkdir -p "$TMP_ROOT"

printf '\033]2;99 Codex\007'
exec codex --sandbox workspace-write --add-dir "$TMP_ROOT" "$@"
