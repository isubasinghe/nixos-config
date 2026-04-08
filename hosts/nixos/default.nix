# Desktop machine (nixos) configuration
{ inputs, outputs, lib, config, pkgs, ... }:

{
  imports = [
    ../common.nix
    ./hardware.nix
    ./xmonad.nix
  ];

  networking.hostName = "nixos";

  boot.loader.grub = {
    enable = true;
    device = "nodev";
    useOSProber = true;
  };

  boot.binfmt.emulatedSystems = [
    "x86_64-windows"
  ];

  hardware = {
    graphics.enable = true;
    nvidia.open = true;
    bluetooth.enable = true;
    cpu.amd.updateMicrocode = true;
  };

  services.blueman.enable = true;
  security.polkit.enable = true;

  services.openssh.settings.PasswordAuthentication = false;

  nix.settings.stalled-download-timeout = 50000;

  networking.extraHosts = ''
    127.0.0.1 dex
    127.0.0.1 minio
    127.0.0.1 postgres
    127.0.0.1 mysql
    127.0.0.1 azurite
  '';

  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "-L"
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };

  system.stateVersion = "24.05";
}
