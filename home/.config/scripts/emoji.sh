#!/usr/bin/env bash
# Emoji picker for i3 (X11): rofi + xclip.
set -euo pipefail

notify() {
  command -v notify-send >/dev/null 2>&1 && notify-send -a emoji "$@"
}

# Fedora's unicode-emoji package ships the data here; EMOJI_TEST can override
# the path on other systems.
EMOJI_TEST="${EMOJI_TEST:-/usr/share/unicode/emoji/emoji-test.txt}"

if [[ ! -r "$EMOJI_TEST" ]]; then
  notify "Emoji data not found" "Install the Unicode emoji test data (unicode-emoji)."
  exit 1
fi

if ! command -v xclip >/dev/null 2>&1; then
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

selection="$(
  printf '%s\n' "$entries" |
    rofi -dmenu -p 'Emoji > ' -l 12 -display-columns 1,2
)" || exit 0
selection="${selection%%$'\t'*}"

[[ -z "$selection" ]] && exit 0

printf '%s' "$selection" | xclip -selection clipboard
