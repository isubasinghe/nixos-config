{ config, lib, pkgs, ... }: 
{ 
  services = {
    gnome.gnome-keyring.enable = true;
    upower.enable = true;
    dbus = {
      enable = true;
      packages = [pkgs.dconf];
    };
    xserver = {
      enable = true; 

      libinput = {
        enable = true; 
        touchpad.disableWhileTyping = true;
      };

      layout = "au";
      xkbVariant = "";
      videoDrivers = ["nvidia"];
      displayManager.defaultSession = "none+xmonad";

      windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
      };

      xkbOptions = "caps:ctrl_modifier";
    };
  };

  systemd.services.upower.enable = true;
}
