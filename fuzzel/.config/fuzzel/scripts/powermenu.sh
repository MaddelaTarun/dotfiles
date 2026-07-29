#!/bin/bash

entries="logout
sleep
reboot
shutdown"

selected=$(echo "$entries" | fuzzel --dmenu --prompt="Power > " -l 4 -w 25) || true
[ -z "$selected" ] && exit 0

case "$selected" in
    logout)   niri msg action quit ;;
    sleep)    systemctl suspend ;;
    reboot)   systemctl reboot ;;
    shutdown) systemctl poweroff ;;
esac
