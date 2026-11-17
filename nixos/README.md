# NixOS

This directory turns the configs in [`../home/`](../home/) into a NixOS system:
i3/X11 only, NVIDIA proprietary driver, and home-manager linking the dotfiles
repo into `/home/t` instead of copying it into the Nix store.

| File | Purpose |
| --- | --- |
| `flake.nix` | inputs: nixpkgs 26.05, home-manager, Helium, Liga SFMono |
| `configuration.nix` | system config: boot, NVIDIA, i3, PipeWire, packages |
| `hardware-configuration.nix` | btrfs subvolumes, `/boot`, ESP, kernel modules |
| `home.nix` | per-user links from `/home/t/dotfiles/home` into `$HOME` |
| `packages/` | `liga-sfmono-nerd-font` and `notwaita-cursor` derivations |

The dotfiles repo remains the source of truth. `home.nix` links every entry with
`mkOutOfStoreSymlink`, so editing `~/.config/i3/config.d/99-bar.conf` edits
`~/dotfiles/home/.config/i3/config.d/99-bar.conf` directly.

## Layout on disk

```text
nvme0n1
├── p1  200M vfat   /boot/efi   shared ESP (Windows boot manager)
├── p3  199G ntfs               Windows
├── p4  818M ntfs               Windows recovery
├── p6  2G   ext4   /boot       reused Fedora /boot (NixOS copies kernels here)
└── p7  499G btrfs
    ├── @nixos    /             new NixOS root (created during install)
    ├── home      /home         preserved Fedora home subvolume
    └── root      (unused)      old Fedora root, kept for rollback
```

`/` and `/home` share the btrfs filesystem but are separate subvolumes. Fedora's
`root` subvolume is left untouched by the install.

## Before installing

1. Commit the NixOS files. Flakes only see files tracked by git, so an
   uncommitted `nixos/` directory is invisible to `nixos-install`:

   ```sh
   cd ~/dotfiles
   git status
   git add -A
   git commit -m "nixos: i3 + home-manager configuration"
   ```

   Pushing is optional, but keeps a copy off the machine being reinstalled.
   `nixos/flake.lock` is committed; if you change an input, run
   `nix flake lock` in `nixos/` and commit the updated lock file (flakes only
   see tracked files).

2. Back up anything not in git (`~/.ssh`, browser profiles, ...). The `home`
   subvolume is preserved, but a backup is still cheap insurance.

3. Boot the NixOS 26.05 installer in **UEFI mode** with Secure Boot disabled.
   `boot.loader.efi.canTouchEfiVariables` and the NVIDIA driver both need this.

## Install

The commands below use the current partition UUIDs. Check them first:

```sh
lsblk -f
```

Expected:

```text
p1  vfat   A06C-0CFB
p6  ext4   e194334f-ccfe-4e67-9a40-62ed688474cb
p7  btrfs  8a2a7b70-e689-48de-8b3d-c22e5cf63c61
```

Then mount the btrfs top level, create `@nixos`, and mount the target:

```sh
# 1. btrfs top-level (subvolid 5) so @nixos can be created
mount -o subvolid=5 /dev/nvme0n1p7 /mnt

# 2. New root subvolume; keep the old "root" subvolume as-is
btrfs subvolume create /mnt/@nixos

# 3. Mount the NixOS root, the preserved home, /boot and the ESP
mount -o subvol=@nixos,compress=zstd:1 /dev/nvme0n1p7 /mnt
mkdir -p /mnt/home /mnt/boot/efi
mount -o subvol=home,compress=zstd:1 /dev/nvme0n1p7 /mnt/home
mount /dev/nvme0n1p6 /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot/efi
```

The dotfiles repo is already on the preserved home subvolume at
`/mnt/home/t/dotfiles`. Pull the commit you just made if you pushed it:

```sh
git -C /mnt/home/t/dotfiles pull
git -C /mnt/home/t/dotfiles submodule update --init --recursive
```

Generate a hardware config and compare it with the committed one. This catches
changed UUIDs or missing kernel modules:

```sh
nixos-generate-config --root /mnt
diff -u /mnt/etc/nixos/hardware-configuration.nix \
        /mnt/home/t/dotfiles/nixos/hardware-configuration.nix
```

Merge any real differences (UUIDs, extra modules) into
`nixos/hardware-configuration.nix`, then install:

```sh
nixos-install --flake /mnt/home/t/dotfiles/nixos#nixos --root /mnt
```

`nixos-install` sets the root password interactively. Set the user password
before rebooting:

```sh
nixos-enter --root /mnt
passwd t
exit
```

Reboot and pick **NixOS** in the GRUB menu. Windows stays in the menu because
GRUB runs `os-prober`; the NixOS bootloader is installed as
`EFI/NixOS/grubx64.efi`, next to (not over) the Windows boot manager.

## First boot

home-manager is applied by the `home-manager-t.service` system service. If the
links under `~/.config` are missing, check:

```sh
systemctl status home-manager-t.service
journalctl -u home-manager-t.service
```

Other checks:

```sh
ls -l ~/.config/i3 ~/.config/kitty ~/.themes
fc-match "Liga SFMono Nerd Font"     # should print a Liga SFMono face
command -v greenclip                 # must be /run/current-system/sw/bin/greenclip
helium --version
nvidia-smi
```

Fedora left an old static greenclip binary at `~/.local/bin/greenclip`; it
shadows the packaged one. Remove it:

```sh
rm ~/.local/bin/greenclip
```

The i3 session appears in LightDM as `none+i3` and is already the default
(`services.displayManager.defaultSession`).

### Flatpak apps

Spotify, Obsidian and VLC are installed per user (NixOS 26.05 only exposes
`services.flatpak.enable`; remotes/apps are not declarative):

```sh
flatpak remote-add --if-not-exists --user flathub \
  https://flathub.org/repo/flathub.flatpakrepo
flatpak install --user flathub \
  com.spotify.Client md.obsidian.Obsidian org.videolan.VLC
```

After installing a new Flatpak, run the cursor sync script (i3 runs it at
startup as well):

```sh
~/.config/scripts/flatpak-gtk-settings.sh
```

## Updating

```sh
cd ~/dotfiles/nixos
nix flake update            # or: nix flake update helium
sudo nixos-rebuild switch --flake .#nixos
```

Then commit `flake.lock` so the next install uses the same inputs.

Rebuild after changing a dotfile? Not necessary for the file *contents* (they
are symlinks), but do it after adding/removing an entry in `home.nix` or
changing a system option:

```sh
sudo nixos-rebuild switch --flake ~/dotfiles/nixos#nixos
```

## Rollback

- **Last good generation:** in GRUB pick an older NixOS generation, or run
  `sudo nixos-rebuild --rollback switch`.
- **List generations:** `nix-env --list-generations --profile /nix/var/nix/profiles/system`.
- **Old Fedora root:** the `root` subvolume is untouched. It is not in the boot
  menu anymore (NixOS owns `/boot` and the ESP entry it created), but its files
  are still reachable, for example by mounting `subvol=root` somewhere.
- **Windows:** untouched; still booted by its own EFI entry and listed by GRUB.

## Troubleshooting

**`nixos-rebuild` cannot see `nixos/`** — the flake directory must be tracked by
git. Run `git add nixos` (and commit) before building, or use
`--flake path:...#nixos`.

**No i3 session / black screen after login** — check
`/run/current-system/sw/share/xsessions/none+i3.desktop`; with LightDM the
session name is `none+i3`, not `i3`.

**NVIDIA** — the proprietary driver is selected with
`services.xserver.videoDrivers = [ "nvidia" ]` and
`hardware.nvidia.modesetting.enable = true`. On a black screen switch to a TTY
(`Ctrl+Alt+F2`) and check `journalctl -b -u display-manager` and `dmesg |
grep -i nvidia`.

**Fonts** — `fc-match "Liga SFMono Nerd Font"` should resolve to
`LigaSFMonoNerdFont-*`. The font comes from the `sf-mono-liga` flake input;
kitty now selects it by family name, not by an absolute file path.

**Wrong cursor size in Flatpak apps** — run
`~/.config/scripts/flatpak-gtk-settings.sh`; Flatpak sandboxes do not read the
host GTK settings.

**Home directory links were backed up** — home-manager moves conflicting files
to `<name>.hm-backup` (configured in `flake.nix`). The previous Fedora home is
otherwise unchanged.

**A home-manager file appeared inside the repo** — never symlink a directory
that home-manager also writes into. `~/.config/environment.d` is therefore a
real directory with per-file links (`home.nix` and `install.sh` both do this),
because home-manager adds `10-home-manager.conf` there. If an older checkout
left `~/.config/environment.d` as a symlink, replace it:

```sh
rm ~/.config/environment.d
mkdir -p ~/.config/environment.d
ln -s ~/dotfiles/home/.config/environment.d/10-qt-theme.conf \
      ~/.config/environment.d/10-qt-theme.conf
```
