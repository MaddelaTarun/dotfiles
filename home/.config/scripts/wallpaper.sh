#!/bin/sh
# Apply the wallpaper once the awww daemon is ready.
# awww-daemon is spawned in parallel, so wait for its socket instead of
# relying on a fixed sleep.

WALLPAPER="$HOME/Pictures/Wallpapers/oil painting/the-cleveland-museum-of-art-Q_ayXo9bZvg-unsplash.jpg"

i=0
while [ "$i" -lt 100 ]; do
    if awww query >/dev/null 2>&1; then
        exec awww img "$WALLPAPER"
    fi
    i=$((i + 1))
    sleep 0.1
done

echo "wallpaper.sh: awww-daemon did not become ready" >&2
exit 1
