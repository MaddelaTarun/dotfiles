set -U fish_greeting ""

if status is-interactive
    set -gx STARSHIP_CONFIG ~/.config/starship/starship.toml
    starship init fish | source
    if type -q zoxide
        zoxide init fish | source
    end
end

if type -q eza
    alias ll "eza -la -g --icons"
end

# vim keybindings: block cursor in normal/visual mode, line cursor in insert
set -g fish_cursor_default block
set -g fish_cursor_insert line
set -g fish_cursor_replace line
set -g fish_cursor_replace_one line
set -g fish_cursor_visual block
set -g fish_key_bindings fish_vi_key_bindings

# Hide the vi mode indicator
function fish_mode_prompt
    echo -n ''
end

# !! and !$ support
function __history_previous_command
    switch (commandline -t)
        case "!"
            commandline -t $history[1]
            commandline -f repaint
        case "*"
            commandline -i !
    end
end

function __history_previous_command_arguments
    switch (commandline -t)
        case "!"
            commandline -t ""
            commandline -f history-token-search-backward
        case "*"
            commandline -i '$'
    end
end

function lt
    set -l eza_args -aT --color=always --group-directories-first --icons
    set -l ignore_patterns
    set -l ignoring 0
    for arg in $argv
        if test "$ignoring" = 1
            set ignore_patterns $ignore_patterns (string split ' ' -- "$arg")
            set ignoring 0
        else if test "$arg" = "-I"
            set ignoring 1
        else if string match -qr -- '^[0-9]+$' "$arg"
            set eza_args $eza_args --level=$arg
        else
            set eza_args $eza_args $arg
        end
    end
    if test (count $ignore_patterns) -gt 0
        set eza_args $eza_args -I (string join '|' $ignore_patterns)
    end
    eza $eza_args
end

# Bind history expansion to BOTH Vi Insert and Vi Normal/Default modes
bind -M default ! __history_previous_command
bind -M insert ! __history_previous_command

bind -M default '$' __history_previous_command_arguments
bind -M insert '$' __history_previous_command_arguments

# Better history
function history
    builtin history --show-time='%F %T '
end

function backup --argument filename
    cp $filename $filename.bak
end

# Copy DIR1 DIR2
function copy
    set count (count $argv | tr -d \n)
    if test "$count" = 2; and test -d "$argv[1]"
        set from (string trim -r -c '/' $argv[1])
        set to $argv[2]
        command cp -r $from $to
    else
        command cp $argv
    end
end

# mkcd DIR
function mkcd
    mkdir -p $argv[1]; and cd $argv[1]
end

# Extract archives
function extract
    set file $argv[1]
    if test -f $file
        switch $file
            case '*.tar.bz2'
                tar xjf $file
            case '*.tar.gz'
                tar xzf $file
            case '*.bz2'
                bunzip2 $file
            case '*.rar'
                unrar x $file
            case '*.gz'
                gunzip $file
            case '*.tar'
                tar xvf $file
            case '*.tbz2'
                tar xjf $file
            case '*.tgz'
                tar xzf $file
            case '*.zip'
                unzip $file
            case '*.Z'
                uncompress $file
            case '*.7z'
                7z x $file
            case '*'
                echo "'$file' cannot be extracted via extract()"
        end
    else
        echo "'$file' is not a valid file"
    end
end


# Java Version Switch (only for manually installed JDKs; NixOS ships Java in the
# Nix store, so these are skipped when the paths do not exist).
function java17
    if not test -x /opt/temurin-17/bin/java
        echo "java17: /opt/temurin-17 is not installed" >&2
        return 1
    end
    set -gx JAVA_HOME /opt/temurin-17
    fish_add_path --prepend --path $JAVA_HOME/bin
    java -version
end

function java25
    if not test -x /usr/lib/jvm/java-25-openjdk/bin/java
        echo "java25: /usr/lib/jvm/java-25-openjdk is not installed" >&2
        return 1
    end
    set -gx JAVA_HOME /usr/lib/jvm/java-25-openjdk
    fish_add_path --prepend --path $JAVA_HOME/bin
    java -version
end

# system
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

# program alias
alias tmux="tmux -u"
alias vi="nvim"

# git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gcl='git clone'
alias gl='git log --oneline'
alias gd='git diff'
alias gpush='git push'
alias gpull='git pull'
alias shutdown='systemctl poweroff'

## Environment
# i3 is the only session; make Chromium/Electron (Helium, Vesktop) and Qt apps
# use X11, and drop any Wayland-only hints inherited from an older session.
set -gx XDG_SESSION_TYPE x11
set -gx XDG_CURRENT_DESKTOP i3
set -gx QT_QPA_PLATFORM xcb
set -e WAYLAND_DISPLAY
set -e MOZ_ENABLE_WAYLAND
set -e ELECTRON_OZONE_PLATFORM_HINT
set -e GDK_BACKEND
set -e SDL_VIDEODRIVER

# qt5ct/qt6ct must be the platform theme, and QT_STYLE_OVERRIDE must not be set
set -gx QT_QPA_PLATFORMTHEME qt5ct
set -e QT_STYLE_OVERRIDE
set -gx EDITOR nvim
set -gx VISUAL nvim

# Hadoop/Spark are not managed by Nix on this machine; only add their paths
# when a manual install exists.
if test -d /usr/local/hadoop
    set -gx HADOOP_HOME /usr/local/hadoop
    fish_add_path $HADOOP_HOME/bin $HADOOP_HOME/sbin
end

if test -d /opt/spark
    set -gx SPARK_HOME /opt/spark
    fish_add_path $SPARK_HOME/bin $SPARK_HOME/sbin
end

if test -d /usr/lib/jvm/java-25-openjdk
    set -gx JAVA_HOME /usr/lib/jvm/java-25-openjdk
end

fish_add_path $HOME/.local/bin
