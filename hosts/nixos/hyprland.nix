{ pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Home Manager supplies Hyprlock and Hypridle; NixOS supplies PAM access.
  security.pam.services.hyprlock = { };

  services = {
    displayManager = {
      sddm.enable = true;
      defaultSession = "hyprland";
    };
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
    };
    gnome.gnome-keyring.enable = true;
    upower.enable = true;
    libinput.enable = true;
  };

  fonts.packages = [ pkgs.nerd-fonts.fira-code ];

  hardware.nvidia.modesetting.enable = true;
}
