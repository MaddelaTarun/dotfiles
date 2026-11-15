#!/usr/bin/env bash
# Emoji picker: fuzzel on Wayland (niri), rofi on X11 (i3).
set -euo pipefail

notify() {
  command -v notify-send >/dev/null 2>&1 && notify-send -a emoji "$@"
}

EMOJI_TEST="${EMOJI_TEST:-/usr/share/unicode/emoji/emoji-test.txt}"

if [[ ! -r "$EMOJI_TEST" ]]; then
  notify "Emoji data not found" "Install the Unicode emoji test data (unicode-emoji)."
  exit 1
fi

if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
  if ! command -v wl-copy >/dev/null 2>&1; then
    notify "wl-copy is not installed" "Install wl-clipboard."
    exit 1
  fi
elif ! command -v xclip >/dev/null 2>&1; then
  notify "xclip is not installed" "Install xclip."
  exit 1
fi

entries="$(
  awk '
    /^[0-9A-F]/ && /; fully-qualified/ {
      if (match($0, /# ([^ ]+) [^ ]+ (.*)$/, m)) {
        printf "%s\t%s\n", m[1], m[2]
      }
    }
  ' "$EMOJI_TEST"
)"

if [[ -n "${WAYLAND_DISPLAY:-}" ]] && command -v fuzzel >/dev/null 2>&1; then
  selection="$(
    printf '%s\n' "$entries" |
      fuzzel --dmenu --with-nth='{1}  {2}' --accept-nth=1 \
        --prompt='Emoji > ' --width=45 --lines=12 --counter
  )" || exit 0
else
  selection="$(
    printf '%s\n' "$entries" |
      rofi -dmenu -p 'Emoji > ' -l 12 -display-columns 1,2
  )" || exit 0
  selection="${selection%%$'\t'*}"
fi

[[ -z "$selection" ]] && exit 0

if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
  printf '%s' "$selection" | wl-copy
else
  printf '%s' "$selection" | xclip -selection clipboard
fi
