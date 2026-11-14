#!/usr/bin/env bash
# Fuzzel clipboard history picker backed by cliphist.
set -euo pipefail

notify() {
  command -v notify-send >/dev/null 2>&1 && notify-send -a clipboard "$@"
}

if ! command -v cliphist >/dev/null 2>&1; then
  notify "cliphist is not installed" "Install it with: sudo dnf install cliphist"
  exit 1
fi

if ! command -v fuzzel >/dev/null 2>&1; then
  notify "fuzzel is not installed"
  exit 1
fi

# Make sure the clipboard watchers are running. They are also started by niri
# at login, but this keeps the script usable if they were stopped.
ensure_watcher() {
  local type="$1"
  local cmd="wl-paste --type ${type} --watch cliphist store"

  if ! pgrep -f -- "$cmd" >/dev/null 2>&1; then
    setsid -f sh -c "exec $cmd" >/dev/null 2>&1 || true
  fi
}

ensure_watcher text
ensure_watcher image

history="$(cliphist list 2>/dev/null || true)"

if [[ -z "$history" ]]; then
  notify "Clipboard history is empty" "Copy something first, then try again."
  exit 0
fi

selection="$(
  {
    printf '__clear__\tClear clipboard history\n'
    printf '%s\n' "$history"
  } | fuzzel --dmenu --with-nth=2 --prompt='Clipboard > ' \
        --width=70 --lines=15 --counter
)" || exit 0

[[ -z "$selection" ]] && exit 0

if [[ "$selection" == __clear__* ]]; then
  cliphist wipe
  notify "Clipboard history cleared"
  exit 0
fi

if ! printf '%s\n' "$selection" | cliphist decode | wl-copy; then
  notify "Could not restore clipboard item"
  exit 1
fi
