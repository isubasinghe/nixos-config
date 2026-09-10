{
  pkgs,
  lib,
  specialArgs,
  ...
}:

let

  polybarOpts = ''
    ${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr
    ${pkgs.feh}/bin/feh --bg-fill ${../../../imgs/wallpaper.jpeg} &
    ${pkgs.pasystray}/bin/pasystray &
    ${pkgs.blueman}/bin/blueman-applet &
    ${pkgs.networkmanagerapplet}/bin/nm-applet --sm-disable --indicator &
  '';
in
{
  xresources.properties = {
    "Xft.dpi" = 96;
    "Xft.autohint" = 0;
    "Xft.hintstyle" = "hintfull";
    "Xft.hinting" = 1;
    "Xft.antialias" = 1;
    "Xft.rgba" = "rgb";
    "Xcursor*theme" = "Vanilla-DMZ-AA";
    "Xcursor*size" = 24;
  };

  home.packages = with pkgs; [
    dialog # Dialog boxes on the terminal (to show key bindings)
    networkmanager_dmenu # networkmanager on dmenu
    networkmanagerapplet # networkmanager applet
    nitrogen # wallpaper manager
    xcape # keymaps modifier
    xkbcomp # keymaps modifier
    xmodmap # keymaps modifier
    xrandr # display manager (X Resize and Rotate protocol)
    scrot
    feh
    xterm
  ];

  # xmonad recompiles itself on X startup into ~/.xmonad/xmonad-x86_64-linux,
  # replacing home-manager's symlink with a regular file. Force-overwrite it
  # so `home-manager switch` never fails on checkLinkTargets again.
  home.file.".xmonad/xmonad-x86_64-linux".force = lib.mkForce true;

  xsession = {    enable = true;

    initExtra = polybarOpts;

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = hp: [
        hp.dbus
        hp.monad-logger
        hp.xmonad-contrib
      ];
      config = ./config.hs;
    };
  };
}
