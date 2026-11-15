#!/usr/bin/env bash
# Power menu: fuzzel on Wayland (niri), rofi on X11 (i3).
set -euo pipefail

on_wayland() {
  [[ -n "${WAYLAND_DISPLAY:-}" ]]
}

lock_screen() {
  if on_wayland && command -v swaylock >/dev/null 2>&1; then
    setsid -f swaylock -f -c 06050c
  else
    # X11: xss-lock is running under i3 and will start i3lock.
    loginctl lock-session
  fi
}

menu() {
  local prompt="$1" lines="$2"

  if on_wayland && command -v fuzzel >/dev/null 2>&1; then
    fuzzel --dmenu --prompt="$prompt" --width=28 --lines="$lines"
  else
    rofi -dmenu -p "$prompt" -l "$lines"
  fi
}

choice="$(
  printf '%s\n' \
    'Lock' \
    'Suspend' \
    'Logout' \
    'Reboot' \
    'Power Off' |
    menu 'Power > ' 5
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
    if [[ -n "${NIRI_SOCKET:-}" ]] && command -v niri >/dev/null 2>&1; then
      niri msg action quit --skip-confirmation
    elif command -v i3-msg >/dev/null 2>&1 && pgrep -x i3 >/dev/null 2>&1; then
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
