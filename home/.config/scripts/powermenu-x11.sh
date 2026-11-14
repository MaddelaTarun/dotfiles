#!/bin/sh
# Small X11 power menu for i3. The Wayland version is powermenu.sh.

choice=$(printf '%s\n' Lock Logout Suspend Reboot Shutdown | dmenu -i -p 'Power:')

case "$choice" in
    Lock)     i3lock -c 101012 ;;
    Logout)   i3-msg exit ;;
    Suspend)  systemctl suspend ;;
    Reboot)   systemctl reboot ;;
    Shutdown) systemctl poweroff ;;
esac
