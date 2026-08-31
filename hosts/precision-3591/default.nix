{ pkgs, ... }:

let
  xmonadLauncher = pkgs.writeShellScript "start-xmonad-nix" ''
    exec /etc/X11/Xsession /home/isubasinghe/.xsession
  '';

  xmonadSession = pkgs.writeText "xmonad-nix.desktop" ''
    [Desktop Entry]
    Name=XMonad (Nix)
    Comment=XMonad managed by Home Manager
    Exec=${xmonadLauncher}
    TryExec=${xmonadLauncher}
    Type=Application
    DesktopNames=XMonad
    X-GDM-SessionRegisters=true
  '';

  hyprlandLauncher = pkgs.writeShellScript "start-hyprland-nix" ''
    mkdir -p /home/isubasinghe/.local/state
    if [ -f /home/isubasinghe/.nix-profile/etc/profile.d/hm-session-vars.sh ]; then
      . /home/isubasinghe/.nix-profile/etc/profile.d/hm-session-vars.sh
    fi
    export PATH="/run/system-manager/sw/bin:$PATH"
    exec /home/isubasinghe/.nix-profile/bin/Hyprland \
      >>/home/isubasinghe/.local/state/hyprland-session.log 2>&1
  '';

  hyprlandSession = pkgs.writeText "hyprland-nix.desktop" ''
    [Desktop Entry]
    Name=Hyprland (Nix)
    Comment=Porple Hyprland session managed by Home Manager
    Exec=${hyprlandLauncher}
    TryExec=${hyprlandLauncher}
    Type=Application
    DesktopNames=Hyprland
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

  systemd.tmpfiles.settings."10-hyprland-nix" = {
    "/usr/share/wayland-sessions/hyprland-nix.desktop"."L+".argument = "${hyprlandSession}";
  };

  security.wrappers.unix_chkpwd = {
    source = "${pkgs.linux-pam}/bin/unix_chkpwd";
    owner = "root";
    group = "root";
    setuid = true;
    permissions = "u+rx,g+x,o+x";
  };

  environment.systemPackages = [
    pkgs.firefox
  ];

  environment.etc."pam.d/hyprlock".text = ''
    #%PAM-1.0

    auth       required   pam_unix.so
    account    required   pam_unix.so
    password   required   pam_unix.so
    session    required   pam_unix.so
  '';
}
