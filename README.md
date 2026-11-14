# dotfiles

Personal Fedora 44 + [niri](https://github.com/YaLTeR/niri) desktop configuration.
The repo mirrors the important parts of `$HOME` under [`home/`](home/) and an
installer symlinks them into place, so editing a config in place also edits the
repo.

## Bootstrap

```sh
git clone https://github.com/MaddelaTarun/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh --dry-run   # optional preview
./install.sh
```

`install.sh`:

- symlinks every item under `home/` into the matching place in `$HOME`;
- moves any existing files/directories to
  `~/.dotfiles-backup-<timestamp>/` before replacing them;
- creates the GTK4 links into `~/.themes/MonoThemeDark`;
- clones the Mono GTK and icon theme sources into `~/.config/` (use
  `--no-clone` to skip this).

After installing, log out and back in (or restart niri) so autostart and session
changes take effect. New fish shells pick up the fish config automatically, and
Neovim installs its `vim.pack` plugins on first launch.

## Layout

```text
home/
├── .config/          # app configs, linked individually into ~/.config
├── .local/bin/       # helper scripts
├── .themes/          # MonoThemeDark GTK theme
├── .bashrc
├── .bash_profile
├── .bash_logout
├── .profile
├── .zshrc
├── .gtkrc-2.0
├── .gitconfig
└── .npmrc
```

`~/.config` itself is never symlinked — only its children are — so unrelated
application state stays untouched.

## What is managed

- niri, waybar, fish, foot, fuzzel, mako, starship, tmux, zathura, btop
- Neovim (`vim.pack`), fastfetch
- GTK 3/4, Qt5/Qt6, Kvantum, nwg-look, xsettingsd, Thunar/LXQt settings
- fontconfig, mimeapps, user dirs, xdg-desktop-portal config
- helper scripts in `~/.config/scripts` and `~/.local/bin`

## Not managed on purpose

- Secrets and auth: `~/.ssh`, `~/.config/gh`, `~/.config/pulse`,
  `~/.config/opencode`
- Large app state and profiles: `vesktop`, `net.imput.helium`, GIMP, Inkscape,
  LibreOffice, OBS, qBittorrent
- Generated state: `~/.config/uv`, `~/.config/nirimod`, `~/.local/share`
- Theme build sources (`Mono-gtk-theme`, `Mono-icon-theme`) are cloned by the
  installer instead of committed.

## Updating

The managed files are symlinks, so edit them normally:

```sh
cd ~/dotfiles
git add -A
git commit -m "update configs"
git push
```

On another machine, or after a reinstall:

```sh
cd ~/dotfiles
git pull
./install.sh
```

## Machine-specific notes

- `home/.config/niri/outputs.kdl` is set up for `HDMI-A-6`; adjust it for your
  display.
- `home/.config/niri/autostart.kdl` points at a wallpaper under
  `~/Pictures/Wallpapers/...`; change the path or add your own image.
- `home/.config/waybar/niri-workspaces` is a prebuilt x86_64 Rust binary. On a
  different architecture or distro, replace it with a matching build.
- `home/.gtkrc-2.0` was exported by nwg-look. Running nwg-look again will
  rewrite it through the symlink.

## Packages and assets

See [`packages.txt`](packages.txt) for the Fedora packages this setup expects.
`install.sh` does not install packages.

The theme expects these local assets, which are not committed because of their
size:

- Liga SFMono Nerd Font — `~/.local/share/fonts/LigaSFMono`
- Lilex Nerd Font — `~/.local/share/fonts/Lilex`
- Notwaita cursors — `~/.local/share/icons/Notwaita-{Black,White}`

## Known notes

- The niri media/brightness keybinds reference `~/.local/bin/mediactl`, which is
  not part of this repo. Install that helper or switch those binds to
  `wpctl`/`playerctl`.
