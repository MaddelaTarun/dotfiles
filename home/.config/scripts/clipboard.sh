#!/usr/bin/env bash
# Clipboard history picker for i3 (X11): rofi + greenclip.
#
# greenclip keeps the history in ~/.cache/greenclip.history and exposes it to
# rofi's script mode; selecting an entry puts it back on the clipboard.
set -euo pipefail

if ! command -v greenclip >/dev/null 2>&1; then
  command -v notify-send >/dev/null 2>&1 &&
    notify-send -a clipboard "greenclip is not installed" \
      "On NixOS it comes from haskellPackages.greenclip; rebuild the system."
  exit 1
fi

# The daemon is started with i3, but keep this usable after a manual restart.
if ! pgrep -x greenclip >/dev/null 2>&1; then
  greenclip daemon >/dev/null 2>&1 &
  sleep 0.3
fi

# No -run-command: that would treat the highlighted clipboard text as a shell
# command. Rofi's default script behavior calls `greenclip print <entry>`,
# which puts the entry back on the clipboard.
exec rofi -modi "clipboard:greenclip print" -show clipboard
