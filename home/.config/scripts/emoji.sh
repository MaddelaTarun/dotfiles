#!/usr/bin/env bash
# Fuzzel emoji picker. Copies the selected emoji to the Wayland clipboard.
set -euo pipefail

notify() {
  command -v notify-send >/dev/null 2>&1 && notify-send -a emoji "$@"
}

EMOJI_TEST="${EMOJI_TEST:-/usr/share/unicode/emoji/emoji-test.txt}"

if [[ ! -r "$EMOJI_TEST" ]]; then
  notify "Emoji data not found" "Install it with: sudo dnf install unicode-emoji"
  exit 1
fi

if ! command -v wl-copy >/dev/null 2>&1; then
  notify "wl-copy is not installed" "Install it with: sudo dnf install wl-clipboard"
  exit 1
fi

selection="$(
  awk '
    /^[0-9A-F]/ && /; fully-qualified/ {
      if (match($0, /# ([^ ]+) [^ ]+ (.*)$/, m)) {
        printf "%s\t%s\n", m[1], m[2]
      }
    }
  ' "$EMOJI_TEST" |
    fuzzel --dmenu --with-nth='{1}  {2}' --accept-nth=1 \
      --prompt='Emoji > ' --width=45 --lines=12 --counter
)" || exit 0

[[ -z "$selection" ]] && exit 0

printf '%s' "$selection" | wl-copy
