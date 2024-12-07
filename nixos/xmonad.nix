{ config, lib, pkgs, ... }: 
{ 
  services = {
    gnome.gnome-keyring.enable = true;
    upower.enable = true;
    dbus = {
      enable = true;
      packages = [pkgs.dconf];
    };

    libinput = {
      enable = true; 
      touchpad.disableWhileTyping = true;
    };

    displayManager.defaultSession = "none+xmonad";

    xserver = {
      enable = true; 
      xkb = {
        variant = "";
        options = "caps:ctrl_modifier";
        layout = "au";
      };
      videoDrivers = ["nvidia"];

      windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
      };

    };
  };

  systemd.services.upower.enable = true;
}
