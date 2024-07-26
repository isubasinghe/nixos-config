# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, outputs, lib, config, pkgs, ... }: 
let
  z3-4-12-2 = pkgs.z3.overrideAttrs(old: rec {
    pname = "z3";
    src = pkgs.fetchFromGitHub {
        owner = "Z3Prover";
        repo = pname;
        rev = "z3-4.12.5";
        sha256 = "sha256-Qj9w5s02OSMQ2qA7HG7xNqQGaUacA1d4zbOHynq5k+A=";
    };
  });
in
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

      # You can also add overlays exported from other flakes: neovim-nightly-overlay.overlays.default

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

      allowBroken = true;

      permittedInsecurePackages = [
        "python3.10-requests-2.28.2"
        "python3.10-cryptography-40.0.1"
      ];
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
    pkgs.gnome.cheese
    pkgs.reptyr
    pkgs.age
    pkgs.pass
    pkgs.infra
    pkgs.croc
    pkgs.tig
    pkgs.nix-output-monitor
    pkgs.verifast
    pkgs.whatsapp-for-linux
    pkgs.zotero
    pkgs.kdash
    pkgs.verible
    pkgs.verilator
    pkgs.cachix
    pkgs.httpie 
    pkgs.jq 
    pkgs.kubectl
    pkgs.protobuf
    pkgs.go
    pkgs.kube3d
    pkgs.rustup
    (pkgs.haskellPackages.ghcWithPackages (ps: [ 
        ps.shake 
        ps.haskell-language-server
        ps.xmonad 
        ps.X11
        ps.xmonad-contrib
        ps.xmonad-extras
        ps.dbus
        ps.turtle
        ps.stack
        ps.language-c
      ]))
    pkgs.gnumake
    pkgs.ormolu
    # pkgs.yarn
    pkgs.yarn
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
    pkgs.hexyl
    pkgs.bingrep
    pkgs.htop
    pkgs.gh
    (pkgs.google-cloud-sdk.withExtraComponents ([pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin]))
    pkgs.k9s
    pkgs.kubespy
    pkgs.gitui
    pkgs.deluge
    pkgs.valgrind
    pkgs.elan
    pkgs.spotify
    pkgs.arandr
    pkgs.asciinema
    pkgs.libnotify
    pkgs.multilockscreen
    pkgs.ouch
    pkgs.gnome.nautilus
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
    pkgs.nixd
    pkgs.zettlr
    pkgs.zathura
    pkgs.pkg-config
    pkgs.openssl
    pkgs.racket
    pkgs.xclip
    pkgs.ipe
    pkgs.screen 
    (pkgs.python311.withPackages (p: with p; [
      jsonpatch
      requests
      pyyaml
      kubernetes
      deepdiff
      exrex
      jsonschema
      pandas
      tabulate
      pytest
      pydantic
      pytest-cov
    ]))
    pkgs.obs-studio
    pkgs.scc
    pkgs.tlaplusToolbox
    pkgs.unzip
    z3-4-12-2
    pkgs.isabelle
    pkgs.insomnia
    (pkgs.agda.withPackages (ps: [
      ps.standard-library
    ]))
    pkgs.nix-index
    pkgs.protoc-gen-go
    pkgs.leetcode-cli
    (pkgs.aspellWithDicts (ds: with ds; [ en en-computers en-science ]))
    pkgs.jdk17
    pkgs.maven
    pkgs.poetry
    pkgs.godot_4
    pkgs.sbt
    pkgs.boogie
    pkgs.nmap
    pkgs.libreoffice-qt
    pkgs.imhex
    pkgs.distrobox
    pkgs.java-language-server
    pkgs.tor
    pkgs.tor-browser
    pkgs.jetbrains.rust-rover
    pkgs.virtualbox
    pkgs.jetbrains.idea-community
  ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "isubasinghe";
    userEmail = "i.subasinghe@unsw.edu.au";
    difftastic = {
      enable = true;
    };
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


  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  colorscheme = lib.mkDefault inputs.nix-colors.colorSchemes.porple;

  home.file = {
    "wallpaper.jpeg".source = ../imgs/wallpaper.jpeg;
  };

  home.file = {
    ".stack/config.yaml".source = ./programs/stack/config.yaml;
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
