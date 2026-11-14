#!/usr/bin/env bash
# Power menu for niri, driven by fuzzel.
set -euo pipefail

lock_screen() {
  if command -v swaylock >/dev/null 2>&1; then
    setsid -f swaylock -f -c 06050c
  else
    loginctl lock-session
  fi
}

choice="$(
  printf '%s\n' \
    'Lock' \
    'Suspend' \
    'Logout' \
    'Reboot' \
    'Power Off' |
    fuzzel --dmenu --prompt='Power > ' --width=28 --lines=5
)" || exit 0

case "$choice" in
  Lock)
    lock_screen
    ;;
  Suspend)
    lock_screen
    sleep 0.5
    systemctl suspend
    ;;
  Logout)
    if command -v niri >/dev/null 2>&1; then
      niri msg action quit --skip-confirmation
    else
      loginctl terminate-session "$XDG_SESSION_ID"
    fi
    ;;
  Reboot)
    systemctl reboot
    ;;
  'Power Off')
    systemctl poweroff
    ;;
  *)
    exit 0
    ;;
esac
