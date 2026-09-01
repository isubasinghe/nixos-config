# Shared home-manager profile applied to all home configurations
{ inputs, outputs, lib, pkgs, ... }:

{
  imports = [
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
    };
  };

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user.name = "isubasinghe";
      user.email = lib.mkDefault "isitha@pipekit.io";
      alias = {
        co = "checkout";
        cob = "checkout -b";
        c = "commit --signoff -m";
        bv = "branch -v";
        rv = "remote -v";
      };
      color.ui = "auto";
      pack.threads = 6;
      merge.conflictStyle = "diff3";
      credential.helper = "cache";
    };
  };

  programs.difftastic = {
    enable = true;
    git.enable = true;
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacs30-nox;
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

  home.file.".stack/config.yaml".source = ../programs/stack/config.yaml;

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
