# Exa Config

if type -q exa
    alias ls "exa -l -g --icons"
end

# Zoxide for FISH

zoxide init fish | source

if status is-interactive
    # Commands to run in interactive sessions can go here
end
