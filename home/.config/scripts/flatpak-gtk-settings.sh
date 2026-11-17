#!/usr/bin/env bash
# Mirror the host cursor theme/size into every Flatpak app's GTK settings.
#
# Flatpak gives each app its own XDG_CONFIG_HOME (~/.var/app/<id>/config), so
# GTK inside the sandbox does not read ~/.config/gtk-{3,4}.0/settings.ini.
# i3 has no XSETTINGS manager either, so GTK falls back to its compiled
# default (Adwaita, 24px). Electron apps (Obsidian, Spotify) resolve the cursor
# through GTK, which is why they showed a larger, different pointer.
#
# Run from i3 (config.d/30-startup.conf); the script is idempotent.
set -euo pipefail

host_settings="$HOME/.config/gtk-3.0/settings.ini"
[ -f "$host_settings" ] || exit 0

theme=$(sed -n 's/^gtk-cursor-theme-name=//p' "$host_settings" | head -n1)
size=$(sed -n 's/^gtk-cursor-theme-size=//p' "$host_settings" | head -n1)
[ -n "${theme:-}" ] && [ -n "${size:-}" ] || exit 0

command -v flatpak >/dev/null 2>&1 || exit 0

set_value() {
  local file=$1 key=$2 value=$3 tmp
  if ! grep -q '^\[Settings\]' "$file" 2>/dev/null; then
    tmp=$(mktemp)
    { printf '[Settings]\n'; [ -f "$file" ] && cat "$file"; } >"$tmp"
    mv "$tmp" "$file"
  fi
  if grep -q "^${key}=" "$file"; then
    sed -i "s|^${key}=.*|${key}=${value}|" "$file"
  else
    printf '%s=%s\n' "$key" "$value" >>"$file"
  fi
}

flatpak list --app --columns=application 2>/dev/null | while IFS= read -r app; do
  [ -n "$app" ] || continue
  for version in 3.0 4.0; do
    dir="$HOME/.var/app/$app/config/gtk-$version"
    mkdir -p "$dir"
    set_value "$dir/settings.ini" gtk-cursor-theme-name "$theme"
    set_value "$dir/settings.ini" gtk-cursor-theme-size "$size"
  done
done
