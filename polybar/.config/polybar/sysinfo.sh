#!/bin/bash

while true; do
    cpu=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print int(usage) "%"}')
    ram=$(free -h | awk '/Mem:/ {print $3 "/" $2}')
    disk=$(df -h / | awk 'NR==2 {print $3 "/" $2}')
    internet=$(ping -c1 8.8.8.8 >/dev/null 2>&1 && echo "Online" || echo "Offline")

    echo "#CLEAR"   # IMPORTANT: clears previous content

    echo "CPU:  $cpu"
    echo "RAM:  $ram"
    echo "Disk: $disk"
    echo "Net:  $internet"

    sleep 2
done | yad --text-info \
    --title="System Info" \
    --width=350 --height=200 \
    --center --no-buttons --undecorated \
    --listen
