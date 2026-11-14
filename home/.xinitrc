#!/bin/sh
# Start the i3 X11 session from a TTY with: startx

[ -f "$HOME/.Xresources" ] && xrdb -merge "$HOME/.Xresources"

export XCURSOR_THEME=Notwaita-White
export XCURSOR_SIZE=20
export XDG_CURRENT_DESKTOP=i3
export XDG_SESSION_DESKTOP=i3
export XDG_SESSION_TYPE=x11

exec i3
