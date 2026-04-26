{ inputs, outputs, lib, config, pkgs, ... }: {
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = "nix-command flakes";

  # Include useful tools for installation
  environment.systemPackages = with pkgs; [
    vim
    git
    rsync
    parted
    gptfdisk
    gpart
    gparted
    home-manager
    wezterm
    firefox
  ];

  # Bundle the data tarball and nixos-config into the ISO
  isoImage.contents = [
    {
      source = ../data-bundle.tar.gz;
      target = "/data-bundle.tar.gz";
    }
    {
      source = ../.;
      target = "/nixos-config";
    }
  ];

  isoImage.isoBaseName = "nixos-isubasinghe";

  # Install script available on the live system
  environment.etc."install.sh" = {
    mode = "0755";
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      echo "=== NixOS Installer for isubasinghe ==="
      echo ""
      echo "This script will:"
      echo "  1. Copy the nixos-config to /mnt/etc/nixos"
      echo "  2. Run nixos-install"
      echo "  3. Extract your personal data to /mnt/home/isithas"
      echo ""
      echo "Before running this, you must:"
      echo "  - Partition your drive"
      echo "  - Format the partitions"
      echo "  - Mount root at /mnt and boot at /mnt/boot"
      echo "  - Update hardware-configuration.nix for the new disk layout"
      echo ""
      read -p "Continue? [y/N] " -n 1 -r
      echo
      [[ $REPLY =~ ^[Yy]$ ]] || exit 1

      echo "==> Copying nixos-config..."
      cp -r /iso/nixos-config /mnt/etc/nixos

      echo "==> Running nixos-install..."
      nixos-install --flake /mnt/etc/nixos#nixos

      echo "==> Extracting personal data..."
      mkdir -p /mnt/home/isithas
      tar xzf /iso/data-bundle.tar.gz -C /mnt/home/isithas --strip-components=1

      echo "==> Fixing ownership..."
      nixos-enter --root /mnt -- chown -R isithas:users /home/isithas

      echo "==> Done! Reboot into your new NixOS system."
    '';
  };
}
