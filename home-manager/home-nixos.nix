# Desktop profile for isithas@nixos; vb-100 keeps the XMonad profile.
{ ... }:

{
  imports = [
    ./home.nix
    ./programs/hyprland
  ];

  # Replace the X11 desktop components inherited from home.nix.
  disabledModules = [
    ./programs/xmonad
    ./programs/xmobar
    ./programs/rofi
    ./programs/wofi
    ./programs/eww
    ./services/picom
    ./services/feh
  ];

  # This desktop has no laptop panel; workspaces follow the active monitor.
  programs.waybar.settings.mainBar."hyprland/workspaces".persistent-workspaces = {
    "*" = [ 1 2 3 4 5 6 7 8 9 10 ];
  };
}
