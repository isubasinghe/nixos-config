# Lab machine (vb-100) configuration
{ inputs, outputs, lib, config, pkgs, ... }:

{
  imports = [
    ../common.nix
    ./hardware.nix
    ./xmonad.nix
  ];

  networking.hostName = "vb-100";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  i18n.defaultLocale = "en_GB.UTF-8";

  services.printing.enable = true;

  services.pipewire.alsa.support32Bit = true;

  services.openssh.settings.PasswordAuthentication = true;

  services.hydra = {
    package = pkgs.hydra_unstable;
    enable = true;
    port = 3030;
    hydraURL = "http://localhost:3030";
    notificationSender = "hydra@localhost";
    buildMachinesFiles = [];
    useSubstitutes = true;
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  system.stateVersion = "23.05";
}
