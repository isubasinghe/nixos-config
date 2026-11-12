{ config, lib, pkgs, ... }:

let
  cfg = config.custom.hyprland.docsearch;

  rofiPackage = config.lib.nixGL.wrap pkgs.rofi;

  # Searches the docsearch index from rofi. docsearch is installed with
  # `cargo install --path .` in ~/Project/docsearch, and reads its config and
  # index from ~/.config/docsearch.
  docsearchRofi = pkgs.writeShellApplication {
    name = "docsearch-rofi";
    runtimeInputs = with pkgs; [
      coreutils
      gnused
      jq
      util-linux
      wl-clipboard
      xdg-utils
    ];
    text = builtins.readFile ./docsearch-rofi.sh;
  };

  # The docs mode is given on the command line, not in rofi/config.rasi, so
  # that hosts without docsearch get no trace of it.
  docsLauncher = lib.concatStringsSep " " [
    "${rofiPackage}/bin/rofi"
    "-show docs"
    "-modi drun,run,window,docs:${docsearchRofi}/bin/docsearch-rofi"
    "-display-docs Docs"
  ];
in
{
  options.custom.hyprland.docsearch.enable =
    lib.mkEnableOption "the SUPER+S rofi launcher for docsearch";

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''
      hl.bind("SUPER + S", hl.dsp.exec_cmd(${builtins.toJSON docsLauncher}))
    '';
  };
}
