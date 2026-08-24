{ pkgs, ... }:

let
  xmonadSession = pkgs.writeText "xmonad-nix.desktop" ''
    [Desktop Entry]
    Name=XMonad (Nix)
    Comment=XMonad managed by Home Manager
    Exec=/etc/X11/Xsession /home/isubasinghe/.xsession
    TryExec=/home/isubasinghe/.xsession
    Type=Application
    DesktopNames=XMonad
    X-GDM-SessionRegisters=true
  '';
in
{
  nixpkgs.hostPlatform = "x86_64-linux";

  # Ubuntu remains responsible for boot, hardware, graphics, and login. This
  # target only installs system-manager-owned, distro-neutral integration.
  systemd.tmpfiles.settings."10-xmonad-nix" = {
    "/usr/share/xsessions/xmonad-nix.desktop"."L+".argument = "${xmonadSession}";
  };
}
