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

  # rofi script mode cannot search after each keystroke. The rofi-blocks plugin
  # can: it sends each change of the typed text to the program.
  rofiBlocks = pkgs.stdenv.mkDerivation {
    pname = "rofi-blocks";
    version = "0.1.0-unstable-2026-09-30";

    src = pkgs.fetchFromGitHub {
      owner = "OmarCastro";
      repo = "rofi-blocks";
      rev = "798104651b6529b1ded5bec15ba6aad3b54bdbac";
      hash = "sha256-CZ2RjNPW9XPsraWXEAqikOl7uiB+DZWDjb14NJc70vY=";
    };

    nativeBuildInputs = with pkgs; [ meson ninja pkg-config ];
    buildInputs = with pkgs; [ rofi-unwrapped glib json-glib cairo ];

    postPatch = ''
      substituteInPlace meson.build --replace-fail \
        "rofiDependency.get_variable('pluginsdir')" \
        "'$out/lib/rofi'"
    '';
  };

  # The plugin and the program are given on the command line, not in
  # rofi/config.rasi, so that hosts without docsearch get no trace of them.
  docsLauncher = lib.concatStringsSep " " [
    "${rofiPackage}/bin/rofi"
    "-plugin-path ${rofiBlocks}/lib/rofi"
    "-show blocks"
    "-modi drun,run,window,blocks"
    "-blocks-wrap ${docsearchRofi}/bin/docsearch-rofi"
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
