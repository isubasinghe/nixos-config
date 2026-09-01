# Home-manager configuration
{ inputs, outputs, lib, config, pkgs, unstable, ... }:

{
  imports = (builtins.concatMap import [
    ./programs
    ./services
    ./packages
  ]) ++ [
    ./profiles/common.nix
  ];

  home = {
    username = "isithas";
    homeDirectory = "/home/isithas";
  };

  programs.git.settings.user.email = "i.subasinghe@unsw.edu.au";

  home.file = {
    "wallpaper.jpeg".source = ../imgs/wallpaper.jpeg;
  };

  home.stateVersion = "24.05";
}
