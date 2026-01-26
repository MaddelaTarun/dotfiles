# Exa Config

if type -q exa
    alias ls "exa -l -g --icons"
end

# Zoxide for FISH

zoxide init fish | source

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Niri & Wayland Session Variables
set -gx QT_QPA_PLATFORM wayland
set -gx XDG_CURRENT_DESKTOP niri
set -gx XDG_SESSION_TYPE wayland
set -gx GNOME_SETUP_DISPLAY :0

# Force OBS and other Qt apps to use Wayland
set -gx OBS_USE_WAYLAND 1
