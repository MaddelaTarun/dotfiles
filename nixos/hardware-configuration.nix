# Filesystems and boot hardware for this machine.
#
# Partition layout (nvme0n1):
#   p1  200M vfat   /boot/efi   shared ESP (Windows boot manager lives here)
#   p6  2G   ext4   /boot       reused Fedora /boot, kernels are copied here
#   p7  499G btrfs  /           new subvolume @nixos
#                   /home       existing subvolume home (preserved from Fedora)
#
# `nixos-generate-config` would regenerate this file; keep the subvolume names
# in sync with the install steps in ./README.md.

{ lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/8a2a7b70-e689-48de-8b3d-c22e5cf63c61";
    fsType = "btrfs";
    options = [
      "subvol=@nixos"
      "compress=zstd:1"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/8a2a7b70-e689-48de-8b3d-c22e5cf63c61";
    fsType = "btrfs";
    options = [
      "subvol=home"
      "compress=zstd:1"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/e194334f-ccfe-4e67-9a40-62ed688474cb";
    fsType = "ext4";
    options = [ "defaults" ];
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/A06C-0CFB";
    fsType = "vfat";
    # Same mount options Fedora used, so Windows keeps seeing the ESP normally.
    options = [
      "umask=0077"
      "shortname=winnt"
    ];
  };

  swapDevices = [ ];

  boot.initrd.availableKernelModules = [
    "btrfs"
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];

  boot.kernelModules = [ "kvm-intel" ];

  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault true;
}
