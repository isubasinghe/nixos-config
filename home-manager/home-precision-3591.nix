{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:

let
  flameshotPackage = config.lib.nixGL.wrap pkgs.flameshot;
  gnomeDisksPackage = config.lib.nixGL.wrap pkgs.gnome-disk-utility;
in
{
  imports = [
    ./programs/zsh
    ./programs/starship
    ./programs/tmux
    ./programs/zoxide
    ./programs/neovim
    ./programs/remind
    ./programs/wezterm
    ./programs/ghostty
    ./programs/xmonad
    ./programs/hyprland
    ./programs/xmobar
    ./packages/cli-tools.nix
    ./packages/dev-tools.nix
    ./packages/academic.nix
    ./profiles/common.nix
  ];

  custom.remind.workReminders = true;

  programs.git.settings.user.email = "isitha.subasinghe@sqc.com";

  targets.genericLinux.enable = true;
  targets.genericLinux.nixGL = {
    packages = inputs.nixgl.packages;
    defaultWrapper = "mesa";
    offloadWrapper = "nvidiaPrime";
    installScripts = [ "mesa" ];
    vulkan.enable = true;
  };

  home = {
    username = "isubasinghe";
    homeDirectory = "/home/isubasinghe";
    stateVersion = "24.05";
  };

  home.sessionPath = [ "/opt/vivado/2026.1/Vivado/bin" ];
  home.sessionVariablesExtra = lib.mkAfter ''
    export PATH="/opt/vivado/2026.1/Vivado/bin:$PATH"
  '';
  programs.zsh.initContent = lib.mkAfter ''
    path+=(/opt/vivado/2026.1/Vivado/bin)
  '';

  # This application is intentionally limited to the Dell Home Manager target.
  home.packages = [
    flameshotPackage
    gnomeDisksPackage
    (config.lib.nixGL.wrap pkgs.slack)
    pkgs.openvpn
    pkgs.networkmanager-openvpn
    pkgs.act
  ];

  systemd.user.services.flameshot = {
    Unit = {
      Description = "Flameshot screenshot tool";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${flameshotPackage}/bin/flameshot";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  xdg.configFile."flameshot/flameshot.ini".text = ''
    [General]
    useGrimAdapter=true
  '';

  dconf.settings."org/gnome/desktop/default-applications/terminal" = {
    exec = "ghostty";
    exec-arg = "";
  };
}
