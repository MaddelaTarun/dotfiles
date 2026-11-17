# System configuration for the i3/X11 NixOS migration.
#
# Partitions (see ./README.md):
#   p1 200M vfat   /boot/efi   (existing ESP, shared with Windows)
#   p6 2G   ext4   /boot       (reused Fedora /boot)
#   p7 499G btrfs  / and /home (new @nixos subvolume, existing home subvolume)
#
# This file is imported by ./flake.nix. User-level dotfile links live in
# ./home.nix; both are applied by `nixos-rebuild switch`.

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  # Not in nixpkgs: SF Mono patched with Nerd Fonts + Fira Code ligatures.
  sfMonoLiga = pkgs.callPackage ./packages/sf-mono-liga.nix {
    src = inputs.sf-mono-liga;
  };

  # Not in nixpkgs: Notwaita White cursor theme (GTK/.Xresources use it).
  notwaitaCursor = pkgs.callPackage ./packages/notwaita-cursor.nix { };

  # Helium is packaged by an external flake because it is not in nixpkgs.
  helium = inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  # ---------------------------------------------------------------------------
  # Nix / nixpkgs
  # ---------------------------------------------------------------------------

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "@wheel"
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.optimise.automatic = true;

  # ---------------------------------------------------------------------------
  # Boot: GRUB on the existing ESP, kernels copied to the ext4 /boot.
  # os-prober keeps the Windows entry in the menu.
  # ---------------------------------------------------------------------------

  boot.loader = {
    timeout = 5;

    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };

    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
      # /boot is only 2G; copying kernels avoids GRUB needing to read btrfs.
      copyKernels = true;
      configurationLimit = 5;
    };
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  # ---------------------------------------------------------------------------
  # Hardware: RTX 3060 drives HDMI-0, so use the proprietary NVIDIA driver.
  # ---------------------------------------------------------------------------

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
    graphics.enable = true;

    nvidia = {
      open = false;
      modesetting.enable = true;
      powerManagement.enable = true;
      nvidiaSettings = true;
    };
  };

  # ---------------------------------------------------------------------------
  # X11 + i3 only (no Wayland session). i3 reads ~/.config/i3/config, which
  # home-manager links to ~/dotfiles.
  # ---------------------------------------------------------------------------

  services.xserver = {
    enable = true;
    xkb.layout = "us";
    videoDrivers = [ "nvidia" ];

    displayManager.lightdm = {
      enable = true;

      greeters.gtk = {
        enable = true;
        iconTheme = {
          package = pkgs.papirus-icon-theme;
          name = "Papirus-Dark";
        };
        cursorTheme = {
          package = notwaitaCursor;
          name = "Notwaita-White";
          size = 20;
        };
      };
    };

    windowManager.i3.enable = true;
  };

  # The display-manager module names the i3 session "none+i3".
  services.displayManager.defaultSession = "none+i3";

  # Keep Qt/Chromium/Electron on X11. The fish config repeats these for
  # interactive shells; this makes GUI apps launched from rofi/i3 consistent.
  environment.variables = {
    QT_QPA_PLATFORM = "xcb";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    ELECTRON_OZONE_PLATFORM_HINT = "x11";
    MOZ_ENABLE_WAYLAND = "0";
    GDK_BACKEND = "x11";
  };

  environment.localBinInPath = true;

  qt = {
    enable = true;
    platformTheme = "qt5ct";
  };

  # ---------------------------------------------------------------------------
  # Audio (PipeWire), networking, time/locale
  # ---------------------------------------------------------------------------

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  time.timeZone = "Asia/Kolkata";
  # Keep the RTC in local time, matching the Windows install.
  time.hardwareClockInLocalTime = true;

  i18n.defaultLocale = "en_IN.UTF-8";
  console.keyMap = "us";

  # ---------------------------------------------------------------------------
  # Desktop integration
  # ---------------------------------------------------------------------------

  programs = {
    fish.enable = true;
    dconf.enable = true;
    command-not-found.enable = true;
  };

  # Flatpak: Spotify, Obsidian and VLC. The remotes/apps are installed in the
  # post-install steps in ./README.md (NixOS 26.05 only exposes enable/package).
  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "gtk" ];
  };

  services.fstrim.enable = true;
  services.btrfs.autoScrub.enable = true;
  services.fwupd.enable = true;

  # ---------------------------------------------------------------------------
  # Fonts: Liga SFMono from the flake input, plus emoji/fallback fonts.
  # The per-user fontconfig in ~/.config/fontconfig is linked by home-manager.
  # ---------------------------------------------------------------------------

  fonts = {
    packages = with pkgs; [
      sfMonoLiga
      noto-fonts
      noto-fonts-color-emoji
      dejavu_fonts
      liberation_ttf
    ];

    fontconfig.defaultFonts = {
      monospace = [
        "Liga SFMono Nerd Font"
        "Noto Color Emoji"
      ];
      sansSerif = [
        "Liga SFMono Nerd Font"
        "Noto Color Emoji"
      ];
      serif = [
        "Liga SFMono Nerd Font"
        "Noto Color Emoji"
      ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  # ---------------------------------------------------------------------------
  # User
  # ---------------------------------------------------------------------------

  users.users.t = {
    isNormalUser = true;
    description = "t";
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "input"
    ];
  };

  # ---------------------------------------------------------------------------
  # Packages
  # ---------------------------------------------------------------------------

  environment.systemPackages = with pkgs; [
    # i3 / X11 session
    i3
    i3status
    i3lock
    xss-lock
    dex
    numlockx
    xinit
    xrandr
    xrdb
    xset
    feh
    picom

    # Terminal and CLI
    fish
    kitty
    starship
    tmux
    btop
    fastfetch
    zoxide
    eza
    git
    gh
    neovim

    # Launcher, clipboard, notifications
    rofi
    xclip
    haskellPackages.greenclip
    libnotify

    # Screenshots
    flameshot

    # Audio
    pavucontrol
    wireplumber
    playerctl

    # Viewers / editors
    mpv
    zathura

    # Desktop utilities
    lxqt.lximage-qt
    xarchiver
    thunar
    networkmanagerapplet

    # Qt/GTK theming (Kvantum is split into Qt5/Qt6 style plugins)
    libsForQt5.qt5ct
    qt6Packages.qt6ct
    nwg-look
    libsForQt5.qtstyleplugin-kvantum
    qt6Packages.qtstyleplugin-kvantum
    papirus-icon-theme

    # Applications
    vesktop
    obs-studio
    helium
    notwaitaCursor

    # Flatpak
    flatpak

    # Archive helpers used by the fish `extract` function
    unzip
    p7zip
    unrar
    file
    curl
    wget
  ];

  system.stateVersion = "26.05";
}
