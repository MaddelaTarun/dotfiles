#!/usr/bin/env bash
# Power menu for i3 (X11): rofi menu, with i3lock started by xss-lock.
set -euo pipefail

lock_screen() {
  # xss-lock is running under i3 and will start i3lock on lock-session.
  loginctl lock-session
}

choice="$(
  printf '%s\n' \
    'Lock' \
    'Suspend' \
    'Logout' \
    'Reboot' \
    'Power Off' |
    rofi -dmenu -p 'Power > ' -l 5
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
    if command -v i3-msg >/dev/null 2>&1 && pgrep -x i3 >/dev/null 2>&1; then
      i3-msg exit
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
