{ pkgs, inputs, ... }:

let
  globalprotect-unwrapped = inputs.globalprotect-openconnect.packages.x86_64-linux.prebuilt;

  # WebKitGTK cannot create an EGL display on this machine's NVIDIA GPU
  # inside the FHS sandbox ("Could not create default EGL display:
  # EGL_BAD_PARAMETER"), leaving the gpgui window blank and aborting the
  # embedded SSO webview. Disabling accelerated compositing makes WebKit
  # render in software instead. nixGL does not apply here because the
  # prebuilt binaries run in their own bubblewrap sandbox.
  globalprotect = pkgs.runCommand "globalprotect-openconnect-wrapped"
    { nativeBuildInputs = [ pkgs.makeWrapper ]; }
    ''
      mkdir -p $out/bin
      for cmd in ${globalprotect-unwrapped}/bin/*; do
        makeWrapper "$cmd" "$out/bin/$(basename "$cmd")" \
          --set WEBKIT_DISABLE_COMPOSITING_MODE 1
      done
      for d in lib libexec share; do
        if [ -e "${globalprotect-unwrapped}/$d" ]; then
          ln -s "${globalprotect-unwrapped}/$d" "$out/$d"
        fi
      done
    '';

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

    # GlobalProtect VPN client (CLI + GUI). The prebuilt package includes the
    # proprietary gpgui binary and expects /run/current-system/sw/bin, which
    # system-manager provides via its linkCurrentSystem symlink.
    globalprotect

    # The GlobalProtect FHS sandbox replaces /usr, hiding Ubuntu's fonts, so
    # provide fonts the sandbox can see via /run/system-manager/sw/share/fonts.
    pkgs.dejavu_fonts

    # The vpnc-script looks up `ip` via PATH, but the FHS sandbox hides the
    # host's /usr/sbin. /run is bound into the sandbox, so an iproute2
    # installed in the system-manager profile is found and routes/DNS get
    # configured on the host.
    pkgs.iproute2
  ];

  # Ubuntu 24.04+ blocks unprivileged user namespaces via AppArmor, which
  # breaks the Nix-built bubblewrap used by the GlobalProtect FHS wrappers
  # ("bwrap: setting up uid map: Permission denied"). This profile allows
  # bubblewrap from the Nix store to create user namespaces.
  environment.etc."apparmor.d/nix-bwrap".text = ''
    abi <abi/4.0>,
    include <tunables/global>

    profile nix-bwrap /nix/store/*-bubblewrap-*/bin/bwrap flags=(unconfined) {
      userns,

      # Site-specific additions and overrides. See local/README for details.
      include if exists <local/nix-bwrap>
    }
  '';

  # Make the fonts installed via system-manager visible to fontconfig, both
  # on the host and inside the GlobalProtect FHS sandbox.
  environment.etc."fonts/local.conf".text = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
    <fontconfig>
      <dir>/run/system-manager/sw/share/fonts</dir>
    </fontconfig>
  '';

  # Allow active sessions to start the GlobalProtect service via pkexec
  # without a password prompt. Ubuntu's polkit doesn't search
  # /run/system-manager/sw/share, so link the shipped rule into /etc.
  environment.etc."polkit-1/rules.d/49-gpgui.rules".source =
    "${globalprotect}/share/polkit-1/rules.d/49-gpgui.rules";

  # Let `sudo <command>` resolve binaries from the system-manager profile.
  environment.etc."sudoers.d/90-system-manager-path" = {
    text = ''
      Defaults secure_path="/run/current-system/sw/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
    '';
    mode = "0440";
  };

  environment.etc."pam.d/hyprlock".text = ''
    #%PAM-1.0

    auth       required   pam_unix.so
    account    required   pam_unix.so
    password   required   pam_unix.so
    session    required   pam_unix.so
  '';
}
