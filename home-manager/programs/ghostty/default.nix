{ pkgs, unstable, config, ... }:
{
  home.packages = [ unstable.ghostty ];

  xdg.configFile."ghostty/config".source = ./config;
}
