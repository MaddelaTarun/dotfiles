#!/usr/bin/env bash
# Volume control for the i3bar (i3status) and media keys.
#
#   up      unmute, then raise the volume one step
#   down    unmute, then lower the volume one step
#   press   mute if unmuted; if already muted, unmute and raise one step
#   toggle  plain mute toggle (used by the keyboard mute key)
#
# Step size defaults to 1%; override with VOLUME_STEP (e.g. VOLUME_STEP=5).
set -euo pipefail

SINK="@DEFAULT_AUDIO_SINK@"
STEP="${VOLUME_STEP:-1}"

is_muted() {
  wpctl get-volume "$SINK" | grep -q '\[MUTED\]'
}

refresh_bars() {
  # i3status redraws on SIGUSR1.
  pkill -SIGUSR1 i3status 2>/dev/null || true
}

case "${1:-}" in
  up)
    wpctl set-mute "$SINK" 0
    wpctl set-volume -l 1.0 "$SINK" "${STEP}%+"
    ;;
  down)
    wpctl set-mute "$SINK" 0
    wpctl set-volume "$SINK" "${STEP}%-"
    ;;
  press)
    if is_muted; then
      wpctl set-mute "$SINK" 0
      wpctl set-volume -l 1.0 "$SINK" "${STEP}%+"
    else
      wpctl set-mute "$SINK" 1
    fi
    ;;
  toggle)
    wpctl set-mute "$SINK" toggle
    ;;
  *)
    echo "usage: $0 {up|down|press|toggle}" >&2
    exit 2
    ;;
esac

refresh_bars
