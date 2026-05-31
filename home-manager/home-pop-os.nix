# Home-manager configuration for Pop!_OS (standalone, no X11/WM modules)
{ inputs, outputs, lib, config, pkgs, unstable, ... }:

{
  imports = [
    ./programs/zsh
    ./programs/starship
    ./programs/tmux
    ./programs/zoxide
    ./programs/neovim
    ./programs/wezterm
    ./programs/ghostty
    ./packages/cli-tools.nix
    ./packages/dev-tools.nix
    ./packages/k8s.nix
    ./packages/academic.nix
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
    username = "isubasinghe";
    homeDirectory = "/home/isubasinghe";
  };

  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "isubasinghe";
    userEmail = "isitha@pipekit.io";
    difftastic.enable = true;
    aliases = {
      co = "checkout";
      cob = "checkout -b";
      c = "commit --signoff -m";
      bv = "branch -v";
      rv = "remote -v";
    };
    extraConfig = {
      color.ui = "auto";
      pack.threads = 6;
      merge.conflictStyle = "diff3";
      credential.helper = "cache";
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
    ".stack/config.yaml".source = ./programs/stack/config.yaml;
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  dconf.settings = {
    "org/gnome/desktop/default-applications/terminal" = {
      exec = "ghostty";
      exec-arg = "";
    };
  };

  home.stateVersion = "24.05";
}
