# Per-user configuration: link the dotfiles repo into $HOME.
#
# Everything under ~/dotfiles/home is the source of truth. Rather than copying
# files into the Nix store, each entry is linked with mkOutOfStoreSymlink, so
# editing ~/.config/i3/config edits ~/dotfiles/home/.config/i3/config and a
# rebuild only has to recreate the symlinks.
#
# Directories are linked per entry (not as one big ~/.config symlink) so
# home-manager can still manage its own files elsewhere.

{ config, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dotfiles/home";

  # Symlink $HOME/<name> to ~/dotfiles/home/<name>.
  link = name: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${name}";

  # Entries under home/.config, linked individually into ~/.config.
  configEntries = [
    "btop"
    "colors.css"
    "fastfetch"
    "fish"
    "flameshot"
    "fontconfig"
    "greenclip.toml"
    "gtk-3.0"
    "gtk-4.0"
    "i3"
    "i3status"
    "kdeglobals"
    "kitty"
    "Kvantum"
    "lximage-qt"
    "lxqt"
    "mimeapps.list"
    "nvim"
    "nwg-look"
    "pavucontrol.ini"
    "qt5ct"
    "qt6ct"
    "QtProject.conf"
    "rofi"
    "scripts"
    "starship"
    "Thunar"
    "tmux"
    "user-dirs.dirs"
    "user-dirs.locale"
    "xarchiver"
    "xfce4"
    "xsettingsd"
    "zathura"
  ];

  # Dotfiles that live directly in $HOME.
  homeFiles = [
    ".Xresources"
    ".bash_logout"
    ".bash_profile"
    ".bashrc"
    ".gitconfig"
    ".gtkrc-2.0"
    ".npmrc"
    ".profile"
    ".zshrc"
  ];

  # Helper scripts, linked individually so the rest of ~/.local/bin stays
  # user-managed (uv, node, local builds, ...).
  localBin = [
    "env"
    "env.fish"
    "qt5ct"
    "qt6ct"
  ];
in
{
  home = {
    username = "t";
    homeDirectory = "/home/t";
    stateVersion = "26.05";

    # Let existing files be moved aside instead of aborting the switch.
    # (Also configured globally in flake.nix.)
    file = { }
      // builtins.listToAttrs (
        map (name: {
          name = ".config/${name}";
          value.source = link ".config/${name}";
        }) configEntries
      )
      // builtins.listToAttrs (
        map (name: {
          name = name;
          value.source = link name;
        }) homeFiles
      )
      // builtins.listToAttrs (
        map (name: {
          name = ".local/bin/${name}";
          value.source = link ".local/bin/${name}";
        }) localBin
      )
      // {
        ".themes/MonoThemeDark".source = link ".themes/MonoThemeDark";

        # Linked per file: home-manager writes its own
        # ~/.config/environment.d/10-home-manager.conf, so the directory itself
        # must stay a real directory.
        ".config/environment.d/10-qt-theme.conf".source =
          link ".config/environment.d/10-qt-theme.conf";

        # emoji.sh reads this path; the package ships emoji-test.txt there.
        ".local/share/unicode/emoji".source =
          "${pkgs.unicode-emoji}/share/unicode/emoji";
      };
  };

  # NixOS owns fontconfig (fonts.fontconfig.defaultFonts in configuration.nix)
  # and ~/.config/fontconfig is linked to the repo. Do not let home-manager
  # write its own conf.d files into that linked directory.
  fonts.fontconfig.enable = false;
}
