# Home-manager configuration
{ inputs, outputs, lib, config, pkgs, unstable, ... }:

{
  imports = (builtins.concatMap import [
    ./programs
    ./services
    ./packages
  ]) ++
    [
      inputs.nix-colors.homeManagerModules.default
    ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
      allowBroken = true;
      permittedInsecurePackages = [
        "python3.10-requests-2.28.2"
        "python3.10-cryptography-40.0.1"
      ];
    };
  };

  home = {
    username = "isithas";
    homeDirectory = "/home/isithas";
  };

  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "isubasinghe";
    userEmail = "i.subasinghe@unsw.edu.au";
    difftastic.enable = true;
    aliases = {
      co = "checkout";
      cob = "checkout -b";
      c = "commit --signoff -m";
      bv = "branch -v";
      rv = "remote -v";
    };
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacs29-nox;
    extraPackages = es: [
      es.lsp-mode
      es.evil
      es.haskell-mode
      es.magit
      es.agda2-mode
      es.idris2-mode
      es.corfu
    ];
  };

  systemd.user.startServices = "sd-switch";

  colorscheme = lib.mkDefault inputs.nix-colors.colorSchemes.porple;

  home.file = {
    "wallpaper.jpeg".source = ../imgs/wallpaper.jpeg;
    ".stack/config.yaml".source = ./programs/stack/config.yaml;
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  home.stateVersion = "24.05";
}
