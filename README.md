# dotfiles

Personal desktop configuration for [i3](https://i3wm.org/), an X11 window
manager. The configs under [`home/`](home/) are shared by two install paths:

- **NixOS** ([`nixos/`](nixos/)) — flakes + home-manager, the primary setup.
  home-manager links `~/dotfiles/home` into `$HOME` with
  `mkOutOfStoreSymlink`, so the repo stays the source of truth.
- **Other X11 machines** — [`install.sh`](install.sh) creates the same
  symlinks and installs the few non-packaged assets.

The repo mirrors the important parts of `$HOME` under [`home/`](home/), so
editing a config in place also edits the repo.

## NixOS

```sh
cd ~/dotfiles
git add -A && git commit -m "update configs"

cd nixos
sudo nixos-rebuild switch --flake .#nixos
```

The system is i3-only (no Wayland session), uses the NVIDIA proprietary driver,
keeps Windows in the GRUB menu, and preserves the existing btrfs `home`
subvolume. Full install and rollback instructions are in
[`nixos/README.md`](nixos/README.md).

## Bootstrap (plain X11 machine)

```sh
git clone https://github.com/MaddelaTarun/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh --dry-run   # optional preview
./install.sh
```

`install.sh`:

- initializes the Neovim submodule ([`MaddelaTarun/nvim`](https://github.com/MaddelaTarun/nvim));
- symlinks every item under `home/` into the matching place in `$HOME`;
- moves any existing files/directories to
  `~/.dotfiles-backup-<timestamp>/` before replacing them;
- creates the GTK4 links into `~/.themes/MonoThemeDark` using relative paths
  stored in the repo;
- clones the Mono GTK and icon theme sources into `~/.config/` (use
  `--no-clone` to skip this).

The Neovim repo is public. If you prefer to fetch it in one step, clone with
`--recurse-submodules`; otherwise `install.sh` initializes it for you.

After installing, log out and back in (or restart i3 with `$mod+Shift+r`) so
autostart and session changes take effect. New fish shells pick up the fish
config automatically, and Neovim installs its `vim.pack` plugins on first
launch.

## Layout

```text
home/
├── .config/          # app configs, linked individually into ~/.config
│   ├── i3/           # i3 config + config.d/ feature files
│   └── nvim/         # git submodule -> MaddelaTarun/nvim
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

nixos/
├── flake.nix                    # nixpkgs 26.05 + home-manager + inputs
├── configuration.nix            # system: boot, NVIDIA, i3, PipeWire, packages
├── hardware-configuration.nix   # btrfs subvolumes, /boot, ESP
├── home.nix                     # dotfile links (mkOutOfStoreSymlink)
├── packages/                    # Liga SFMono + Notwaita cursor derivations
└── README.md                    # install / rollback instructions
```

`~/.config` itself is never symlinked — only its children are — so unrelated
application state stays untouched.

`home/.config/nvim` is a submodule, so the Neovim config is a separate repo
with its own history. Everything else in `home/` is tracked directly by the
dotfiles repo.

## i3 (X11)

The i3 config is split by feature so each area is easy to find:

```text
home/.config/i3/
├── config
└── config.d/
    ├── 10-variables.conf          $mod
    ├── 20-appearance.conf         font, gaps, borders, colors, layout
    ├── 30-startup.conf            xrandr, autostart, locker, wallpaper, key repeat
    ├── 40-applications.conf       terminal, launcher, clipboard, power menu, emoji picker
    ├── 50-window-management.conf  focus/move/split/fullscreen/layout/floating
    ├── 60-workspaces.conf         workspace names, app → workspace rules, ws keys
    ├── 70-resize.conf             resize mode + direct resize keys
    ├── 80-media-keys.conf         volume/mute keys
    ├── 90-session.conf            reload/restart/exit
    └── 99-bar.conf                i3bar + i3status
```

Edit the relevant file and reload with `$mod+Shift+c` (restart with
`$mod+Shift+r`). Relative `include` paths are resolved from `~/.config/i3/`.

Apps are pinned to workspaces, no matter which workspace you launch them from:

| Workspace | Apps |
| --------- | ---- |
| 1 | Helium |
| 2 | kitty |
| 3 | Spotify, Vesktop, Obsidian |
| 4 | OBS Studio |

The i3 launcher binding starts rofi directly. Clipboard history is provided by
[greenclip](https://github.com/erebe/greenclip): the daemon starts with i3 and
`$mod+p` opens its history in rofi (`~/.config/scripts/clipboard.sh`).

[Flameshot](https://flameshot.org/) starts with i3 and lives in the i3bar tray
(`tray_output primary`). Its config uses native X11 capture
(`useX11LegacyScreenshot`): Flameshot 14 defaults to the freedesktop portal,
but the GTK backend does not expose the Screenshot interface on i3, so portal
capture fails.

## Neovim

- Repo: <https://github.com/MaddelaTarun/nvim> (public)
- Local path: `~/dotfiles/home/.config/nvim`, reachable through the
  `~/.config/nvim` symlink
- Plugin manager: Neovim's built-in `vim.pack`; plugins install on first launch

Edit Neovim like any other repo:

```sh
cd ~/.config/nvim
git add -A
git commit -m "update nvim config"
git push
```

Then record the new commit in the dotfiles repo:

```sh
cd ~/dotfiles
git add home/.config/nvim
git commit -m "bump nvim config"
git push
```

To pick up a newer Neovim config on another machine:

```sh
cd ~/dotfiles
git submodule update --remote home/.config/nvim
git add home/.config/nvim
git commit -m "bump nvim config"
```

## What is managed

- i3, i3status, rofi, kitty, picom
- `.Xresources` (cursor theme/size)
- greenclip (clipboard history config; the daemon comes from the distro on
  NixOS and from a static binary elsewhere)
- flameshot (screenshot tool config)
- fish, starship, tmux, zathura, btop
- Neovim (`vim.pack`, separate submodule), fastfetch
- GTK 3/4, Qt5/Qt6, Kvantum, nwg-look, xsettingsd, Thunar/LXQt settings
- fontconfig, mimeapps, user dirs
- helper scripts in `~/.config/scripts` and `~/.local/bin`

## Not managed on purpose

- Secrets and auth: `~/.ssh`, `~/.config/gh`, `~/.config/pulse`,
  `~/.config/opencode`
- Large app state and profiles: `vesktop`, `net.imput.helium`, GIMP, Inkscape,
  LibreOffice, OBS, qBittorrent
- Generated state: `~/.config/uv`, `~/.local/share`
- Theme build sources (`Mono-gtk-theme`, `Mono-icon-theme`) are cloned by the
  installer instead of committed.

## Updating

The managed files are symlinks, so edit them normally. Except for Neovim (see
above), changes are committed here:

```sh
cd ~/dotfiles
git add -A
git commit -m "update configs"
git push
```

On NixOS, rebuild after adding/removing a link or changing a system option:

```sh
sudo nixos-rebuild switch --flake ~/dotfiles/nixos#nixos
```

On another plain X11 machine, or after a reinstall:

```sh
cd ~/dotfiles
git pull
git submodule update --init --recursive
./install.sh
```

## Machine-specific notes

- `home/.config/i3/config.d/30-startup.conf` sets the display mode for
  `HDMI-0` and points at another wallpaper under `~/Pictures/Wallpapers/...`;
  adjust both for your hardware.
- On NixOS, greenclip is `haskellPackages.greenclip`. Do not keep an old static
  binary at `~/.local/bin/greenclip`: it shadows the packaged one.
- The kitty font is selected by family name (`Liga SFMono Nerd Font`). On
  NixOS it is installed system-wide from the `sf-mono-liga` flake input; on
  other machines copy the files to `~/.local/share/fonts` and run `fc-cache`.
- `home/.gtkrc-2.0` was exported by nwg-look. Running nwg-look again will
  rewrite it through the symlink.
- Flatpak apps do not share the host `XDG_CONFIG_HOME`, so GTK inside the
  sandbox never reads `~/.config/gtk-3.0/settings.ini`. With no XSETTINGS
  manager on i3 it falls back to `Adwaita`/24px, which is why Electron apps
  (Obsidian, Spotify) showed a different, larger cursor. i3 runs
  `~/.config/scripts/flatpak-gtk-settings.sh`, which copies the host cursor
  theme/size into each app's `~/.var/app/<id>/config/gtk-{3,4}.0/settings.ini`.
  Run it by hand after installing a new Flatpak app.

## Packages and assets

On NixOS every package is declared in
[`nixos/configuration.nix`](nixos/configuration.nix); see
[`packages.txt`](packages.txt) for the full list and where the non-nixpkgs
pieces come from. `install.sh` does not install packages.
