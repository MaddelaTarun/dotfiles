#!/usr/bin/env bash
#
# Install these dotfiles by symlinking everything under home/ into $HOME.
#
# Existing files are moved to ~/.dotfiles-backup-<timestamp>/ first.
#
# Usage:
#   ./install.sh              initialize the nvim submodule, link configs, clone themes
#   ./install.sh --dry-run    show what would happen
#   ./install.sh --no-clone   skip cloning the Mono theme sources
#   ./install.sh --help

set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$REPO_DIR/home"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
DRY_RUN=0
CLONE_THEMES=1

usage() {
    cat <<'EOF'
Usage: ./install.sh [options]

Options:
  -n, --dry-run   Show what would be linked without changing anything
      --no-clone  Do not clone Mono-gtk-theme / Mono-icon-theme
  -h, --help      Show this help

The installer symlinks every item under home/ into the matching place in
$HOME. Existing files and directories are moved to
~/.dotfiles-backup-<timestamp>/.
EOF
}

for arg in "$@"; do
    case "$arg" in
        -n|--dry-run) DRY_RUN=1 ;;
        --no-clone)   CLONE_THEMES=0 ;;
        -h|--help)    usage; exit 0 ;;
        *) echo "Unknown option: $arg" >&2; usage >&2; exit 2 ;;
    esac
done

[ -d "$SOURCE_DIR" ] || {
    echo "Missing source directory: $SOURCE_DIR" >&2
    exit 1
}

if [ "$DRY_RUN" -eq 0 ]; then
    mkdir -p "$HOME/.local/bin" "$HOME/.themes"
fi

run() {
    if [ "$DRY_RUN" -eq 1 ]; then
        printf 'would:'
        printf ' %q' "$@"
        printf '\n'
    else
        "$@"
    fi
}

backup_existing() {
    local target="$1"
    local rel="${target#"$HOME"/}"
    local dest="$BACKUP_DIR/$rel"

    echo "backing up $target -> $dest"
    run mkdir -p "$(dirname -- "$dest")"
    run mv -- "$target" "$dest"
}

link_item() {
    local src="$1"
    local dest="$2"

    if [ -L "$dest" ] && [ "$(readlink -- "$dest")" = "$src" ]; then
        return 0
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        backup_existing "$dest"
    fi

    echo "linking $dest -> $src"
    run mkdir -p "$(dirname -- "$dest")"
    run ln -sfn -- "$src" "$dest"
}

link_children() {
    local src_dir="$1"
    local dest_dir="$2"
    local src name

    [ -d "$src_dir" ] || return 0

    for src in "$src_dir"/* "$src_dir"/.[!.]* "$src_dir"/..?*; do
        [ -e "$src" ] || [ -L "$src" ] || continue
        name="$(basename -- "$src")"
        link_item "$src" "$dest_dir/$name"
    done
}

# --- Neovim submodule ------------------------------------------------------

# Neovim lives in a separate repository (MaddelaTarun/nvim) and is vendored
# here as a submodule. Initialize it before linking so ~/.config/nvim is never
# an empty directory.
NVIM_DIR="$SOURCE_DIR/.config/nvim"
NVIM_URL="https://github.com/MaddelaTarun/nvim.git"

if [ ! -f "$NVIM_DIR/init.lua" ]; then
    echo "initializing Neovim config from $NVIM_URL"

    if git -C "$REPO_DIR" rev-parse --git-dir >/dev/null 2>&1; then
        # Normal case: this is a clone of the dotfiles repo with a submodule.
        if ! run git -C "$REPO_DIR" submodule update --init --recursive; then
            cat >&2 <<EOF
error: could not initialize the Neovim submodule.

$NVIM_URL is a private repository. Authenticate first (gh auth login) or
clone it manually:

    git clone $NVIM_URL "$NVIM_DIR"
EOF
            exit 1
        fi
    elif [ -d "$NVIM_DIR/.git" ]; then
        echo "Neovim config already present: $NVIM_DIR"
    elif [ -d "$NVIM_DIR" ] && [ -n "$(ls -A "$NVIM_DIR" 2>/dev/null)" ]; then
        echo "error: $NVIM_DIR exists but does not look like the Neovim config." >&2
        echo "       Move it aside, then run this installer again." >&2
        exit 1
    elif ! run git clone "$NVIM_URL" "$NVIM_DIR"; then
        cat >&2 <<EOF
error: could not clone $NVIM_URL.

The repository is private. Authenticate first (gh auth login) or clone it
manually:

    git clone $NVIM_URL "$NVIM_DIR"
EOF
        exit 1
    fi
fi

# --- Links -----------------------------------------------------------------

# Top-level files. Directories that need per-entry links are handled below.
for src in "$SOURCE_DIR"/* "$SOURCE_DIR"/.[!.]* "$SOURCE_DIR"/..?*; do
    [ -e "$src" ] || [ -L "$src" ] || continue
    name="$(basename -- "$src")"
    case "$name" in
        .config|.local|.themes) continue ;;
    esac
    link_item "$src" "$HOME/$name"
done

# Never link ~/.config itself; only its children.
link_children "$SOURCE_DIR/.config" "$HOME/.config"

# Link individual helper scripts so the rest of ~/.local/bin is untouched.
link_children "$SOURCE_DIR/.local/bin" "$HOME/.local/bin"

# Link individual themes so other themes in ~/.themes are untouched.
link_children "$SOURCE_DIR/.themes" "$HOME/.themes"

# GTK4 expects its CSS/assets to live directly in ~/.config/gtk-4.0.
# Recreate those links with absolute paths so the repo is portable.
GTK4_THEME="$HOME/.themes/MonoThemeDark/gtk-4.0"
GTK4_DEST="$HOME/.config/gtk-4.0"
if [ -d "$GTK4_THEME" ]; then
    run mkdir -p "$GTK4_DEST"
    for f in assets gtk.css gtk-dark.css; do
        [ -e "$GTK4_THEME/$f" ] || continue
        if [ "$DRY_RUN" -eq 1 ]; then
            echo "would link $GTK4_DEST/$f -> $GTK4_THEME/$f"
        else
            ln -sfn "$GTK4_THEME/$f" "$GTK4_DEST/$f"
        fi
    done
fi

# --- Optional external sources --------------------------------------------

clone_repo() {
    local url="$1"
    local dest="$2"

    if [ -d "$dest/.git" ]; then
        echo "already cloned: $dest"
    elif [ -e "$dest" ]; then
        echo "skipping clone (path exists and is not a git repo): $dest"
    else
        echo "cloning $url -> $dest"
        run git clone --depth 1 "$url" "$dest" \
            || echo "warning: failed to clone $url" >&2
    fi
}

if [ "$CLONE_THEMES" -eq 1 ]; then
    clone_repo https://github.com/witalihirsch/Mono-gtk-theme.git "$HOME/.config/Mono-gtk-theme"
    clone_repo https://github.com/witalihirsch/Mono-icon-theme.git "$HOME/.config/Mono-icon-theme"
fi

# --- Done ------------------------------------------------------------------

cat <<EOF

Done.

Backups:       $BACKUP_DIR
Neovim:        $NVIM_DIR (MaddelaTarun/nvim)
Theme sources: ~/.config/Mono-gtk-theme, ~/.config/Mono-icon-theme

Log out and back in (or restart niri) so autostart and session changes apply.
New shells pick up the fish config automatically.
EOF
