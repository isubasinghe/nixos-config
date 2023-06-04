# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, outputs, lib, config, pkgs, ... }: 

{
  # You can import other home-manager modules here
  imports = (builtins.concatMap import [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example


    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ./programs
    ./services
  ]) ++ 
    [
      inputs.nix-colors.homeManagerModules.default
    ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };
  };

  # TODO: Set your username
  home = {
    username = "isithas";
    homeDirectory = "/home/isithas";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = [
    pkgs.neovim
    pkgs.httpie 
    pkgs.jq 
    pkgs.kubectl
    pkgs.protobuf
    pkgs.go
    pkgs.kube3d
    pkgs.rustup
    (pkgs.haskellPackages.ghcWithPackages (ps: [ 
        ps.shake 
        ps.stack 
        ps.haskell-language-server
        ps.ormolu
        ps.xmonad 
        ps.X11
        ps.xmonad-contrib
        ps.xmonad-extras
        ps.dbus
      ]))
      pkgs.gnumake
    pkgs.yarn
    # (pkgs.yarn.override {nodejs = pkgs.nodejs-19_x;})
    pkgs.nodejs
    pkgs.lsof
    pkgs.vscode
    pkgs.gopls
    pkgs.ccls
    (pkgs.nodePackages.typescript-language-server)
    (pkgs.nodePackages.pyright)
    pkgs.gofumpt
    pkgs.delve
    pkgs.gdlv
    pkgs.gotools
    pkgs.clang-tools
    pkgs.texlab
    pkgs.tikzit
    pkgs.texlive.combined.scheme-full
    pkgs.watson
    pkgs.bat 
    pkgs.procs
    pkgs.du-dust
    pkgs.tealdeer
    pkgs.delta
    pkgs.duf
    pkgs.fd
    pkgs.ripgrep
    pkgs.silver-searcher
    pkgs.fzf
    pkgs.mcfly
    pkgs.bottom
    pkgs.zoxide
    pkgs.exa
    pkgs.hexyl
    pkgs.bingrep
    pkgs.htop
    pkgs.gh
    (pkgs.google-cloud-sdk.withExtraComponents ([pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin]))
    pkgs.octant
    pkgs.octant-desktop
    pkgs.k9s
    pkgs.kubespy
    pkgs.gitui
    pkgs.deluge
    pkgs.helix
    pkgs.valgrind
    pkgs.elan
    pkgs.spotify
    pkgs.arandr
    pkgs.asciinema
    pkgs.libnotify
    pkgs.multilockscreen
    pkgs.ouch
    pkgs.paprefs
    pkgs.pavucontrol
    pkgs.pasystray
    pkgs.playerctl
    pkgs.pulsemixer
    pkgs.rage
    pkgs.screenkey
    pkgs.vlc 
    pkgs.xsel
    pkgs.feh
    pkgs.ffmpeg
  ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "isubasinghe";
    userEmail = "isubasinghe@student.unimelb.edu.au";
  };
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";


  stylix.image = ../imgs/wallpaper.jpg;

  colorscheme = lib.mkDefault inputs.nix-colors.colorSchemes.porple;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
