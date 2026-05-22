alias tmux "tmux -u"
alias vi "nvim"

# Exa Config

if type -q exa
    alias ls "exa -l -g --icons"
end

# Zoxide for FISH

zoxide init fish | source

# Starship
set -gx STARSHIP_CONFIG ~/.config/starship/starship.toml
starship init fish | source

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

# VI Mode in Fish

set -g fish_key_bindings fish_vi_key_bindings
function repaint_on_mode_change --on-variable fish_bind_mode
    commandline -f repaint 2>/dev/null
end

string match -q "$TERM_PROGRAM" "kiro" and . (kiro --locate-shell-integration-path fish)

# Use Neovim as MANPAGER
set -gx MANPAGER "nvim +Man!"


set -gx STUDIO_JDK /usr/lib/jvm/java-21-openjdk  # Or your current JDK path
set -gx _JAVA_AWT_WM_NONREPARENTING 1
set -gx ANDROID_HOME /opt/android-sdk
set -gx PATH $PATH $ANDROID_HOME/cmdline-tools/latest/bin $ANDROID_HOME/platform-tools $ANDROID_HOME/emulator
