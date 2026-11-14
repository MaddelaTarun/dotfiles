#!/usr/bin/env bash
# Night light toggle / auto script for wlsunset
# Usage: nightlight [on|off|toggle|auto]

set -euo pipefail

# Location for wlsunset (approximate - adjust for your city)
LAT="28.6"
LON="77.2"

# Temperature settings
DAY_TEMP=6500
NIGHT_TEMP=3500

# Config file to track state
STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/nightlight-state"

is_night() {
    local hour=$(date +%H)
    # Night: before 6am (0-5) OR after 6pm (18-23)
    (( hour < 6 || hour >= 18 ))
}

get_state() {
    [[ -f "$STATE_FILE" ]] && cat "$STATE_FILE" || echo "off"
}

set_state() {
    echo "$1" > "$STATE_FILE"
}

start_wlsunset() {
    # Kill any existing wlsunset
    pkill -x wlsunset 2>/dev/null || true
    # Start with night temperature
    wlsunset -l "$LAT" -L "$LON" -t "$NIGHT_TEMP" -T "$DAY_TEMP" &
    disown
}

stop_wlsunset() {
    pkill -x wlsunset 2>/dev/null || true
}

case "${1:-auto}" in
    on)
        start_wlsunset
        set_state "on"
        notify-send "Night Light" "Enabled" -u low
        ;;
    off)
        stop_wlsunset
        set_state "off"
        notify-send "Night Light" "Disabled" -u low
        ;;
    toggle)
        if [[ "$(get_state)" == "on" ]]; then
            stop_wlsunset
            set_state "off"
            notify-send "Night Light" "Disabled" -u low
        else
            start_wlsunset
            set_state "on"
            notify-send "Night Light" "Enabled" -u low
        fi
        ;;
    auto)
        if is_night; then
            start_wlsunset
            set_state "on"
        else
            stop_wlsunset
            set_state "off"
        fi
        ;;
    status)
        if pgrep -x wlsunset >/dev/null; then
            echo "on"
        else
            echo "off"
        fi
        ;;
    *)
        echo "Usage: $0 {on|off|toggle|auto|status}"
        exit 1
        ;;
esac