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

  # This application is intentionally limited to the Dell Home Manager target.
  home.packages = [
    flameshotPackage
    (config.lib.nixGL.wrap pkgs.slack)
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

  dconf.settings."org/gnome/desktop/default-applications/terminal" = {
    exec = "ghostty";
    exec-arg = "";
  };
}
