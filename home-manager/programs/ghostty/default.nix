{ pkgs, unstable, config, ... }:
{
  home.packages = [ (config.lib.nixGL.wrap unstable.ghostty) ];

  xdg.configFile."ghostty/config".source = ./config;
}
