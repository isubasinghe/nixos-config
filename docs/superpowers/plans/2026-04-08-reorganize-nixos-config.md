# Reorganize NixOS Config Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorganize the NixOS configuration into a host-based directory structure, extract shared config, remove dead code, and split the monolithic home-manager package list into grouped files.

**Architecture:** Move from flat `nixos/` to `hosts/<hostname>/` dirs with a shared `hosts/common.nix`. Split `home.packages` into domain-grouped files under `home-manager/packages/`. Remove unused modules (nixvim, empty stubs) and legacy files.

**Tech Stack:** Nix, NixOS, home-manager, flakes

---

### Task 1: Create host directory structure and move files

**Files:**
- Create: `hosts/nixos/default.nix` (from `nixos/configuration.nix`, host-specific parts only)
- Create: `hosts/nixos/hardware.nix` (move from `nixos/hardware-configuration.nix`)
- Create: `hosts/nixos/xmonad.nix` (move from `nixos/xmonad.nix`)
- Create: `hosts/nixos/plasma5.nix` (move from `nixos/plasma5.nix`)
- Create: `hosts/vb-100/default.nix` (from `nixos/lab-config.nix`, host-specific parts only)
- Create: `hosts/vb-100/hardware.nix` (move from `nixos/lab-hardware-config.nix`)
- Create: `hosts/vb-100/xmonad.nix` (copy from `nixos/xmonad.nix` -- shared for now, can diverge later)
- Create: `hosts/common.nix` (shared config extracted from both hosts)

- [ ] **Step 1: Create `hosts/common.nix`**

This file contains everything shared between both hosts: nixpkgs config, overlays, nix settings, user definition, locale, openssh base, docker, system packages, fonts, dconf.

```nix
# Shared NixOS configuration applied to all hosts
{ inputs, outputs, lib, config, pkgs, ... }:

{
  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    config = {
      allowUnfree = true;
    };
  };

  nix = {
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      trusted-public-keys = [
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      ];
      substituters = [
        "https://cache.iog.io"
      ];
      trusted-users = [
        "isithas"
      ];
    };
  };

  networking.networkmanager.enable = true;

  time.timeZone = "Australia/Sydney";
  i18n.defaultLocale = "en_AU.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  users.users.isithas = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" "audio" ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      GatewayPorts = "yes";
    };
  };

  services.dbus.enable = true;

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    firefox
    os-prober
    grub2
    discord
    slack
    gptfdisk
    wezterm
    _1password-gui
    parted
    gpart
    gparted
    git
    gcc
    cmake
    bash
    home-manager
  ];

  fonts.fontconfig.enable = true;
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  programs.dconf.enable = true;
}
```

- [ ] **Step 2: Create `hosts/nixos/default.nix`**

Desktop-specific config only (boot, nvidia, hostname, bluetooth, extra hosts, auto-upgrade, etc.).

```nix
# Desktop machine (nixos) configuration
{ inputs, outputs, lib, config, pkgs, ... }:

{
  imports = [
    ../common.nix
    ./hardware.nix
    ./xmonad.nix
  ];

  networking.hostName = "nixos";

  boot.loader.grub = {
    enable = true;
    device = "nodev";
    useOSProber = true;
  };

  boot.binfmt.emulatedSystems = [
    "x86_64-windows"
  ];

  hardware = {
    graphics.enable = true;
    nvidia.open = true;
    bluetooth.enable = true;
    cpu.amd.updateMicrocode = true;
  };

  services.blueman.enable = true;
  security.polkit.enable = true;

  services.openssh.settings.PasswordAuthentication = false;

  nix.settings.stalled-download-timeout = 50000;

  networking.extraHosts = ''
    127.0.0.1 dex
    127.0.0.1 minio
    127.0.0.1 postgres
    127.0.0.1 mysql
    127.0.0.1 azurite
  '';

  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "-L"
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };

  system.stateVersion = "24.05";
}
```

- [ ] **Step 3: Create `hosts/nixos/hardware.nix`**

Copy `nixos/hardware-configuration.nix` verbatim to `hosts/nixos/hardware.nix`.

- [ ] **Step 4: Create `hosts/nixos/xmonad.nix`**

Copy `nixos/xmonad.nix` verbatim to `hosts/nixos/xmonad.nix`.

- [ ] **Step 5: Create `hosts/nixos/plasma5.nix`**

Copy `nixos/plasma5.nix` verbatim to `hosts/nixos/plasma5.nix`.

- [ ] **Step 6: Create `hosts/vb-100/default.nix`**

Lab-specific config only.

```nix
# Lab machine (vb-100) configuration
{ inputs, outputs, lib, config, pkgs, ... }:

{
  imports = [
    ../common.nix
    ./hardware.nix
    ./xmonad.nix
  ];

  networking.hostName = "vb-100";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  i18n.defaultLocale = "en_GB.UTF-8";

  services.printing.enable = true;

  services.pipewire.alsa.support32Bit = true;

  services.openssh.settings.PasswordAuthentication = true;

  services.hydra = {
    package = pkgs.hydra_unstable;
    enable = true;
    port = 3030;
    hydraURL = "http://localhost:3030";
    notificationSender = "hydra@localhost";
    buildMachinesFiles = [];
    useSubstitutes = true;
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  system.stateVersion = "23.05";
}
```

- [ ] **Step 7: Create `hosts/vb-100/hardware.nix`**

Copy `nixos/lab-hardware-config.nix` verbatim to `hosts/vb-100/hardware.nix`.

- [ ] **Step 8: Create `hosts/vb-100/xmonad.nix`**

Copy `nixos/xmonad.nix` verbatim to `hosts/vb-100/xmonad.nix`.

- [ ] **Step 9: Commit**

```bash
git add hosts/
git commit -m "refactor: create host-based directory structure with shared common.nix"
```

---

### Task 2: Split home-manager packages into grouped files

**Files:**
- Create: `home-manager/packages/default.nix`
- Create: `home-manager/packages/dev-tools.nix`
- Create: `home-manager/packages/cli-tools.nix`
- Create: `home-manager/packages/desktop.nix`
- Create: `home-manager/packages/k8s.nix`
- Create: `home-manager/packages/academic.nix`
- Modify: `home-manager/home.nix` (remove inline packages, import packages dir)

- [ ] **Step 1: Create `home-manager/packages/dev-tools.nix`**

Languages, LSPs, compilers, build tools.

```nix
# Development tools: languages, LSPs, compilers, build tools
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    go
    rustup
    (haskellPackages.ghcWithPackages (ps: [
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
    gnumake
    ormolu
    nodejs
    yarn
    (python311.withPackages (p: with p; [
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
      uv
    ]))
    gopls
    ccls
    (nodePackages.typescript-language-server)
    pyright
    gofumpt
    delve
    gdlv
    gotools
    clang-tools
    texlab
    java-language-server
    nixd
    gcc
    cmake
    pkg-config
    openssl
    protobuf
    protoc-gen-go
    jdk17
    maven
    sbt
    poetry
    tree-sitter
    vscode
    jetbrains.rust-rover
    jetbrains.idea-community
    valgrind
  ];
}
```

- [ ] **Step 2: Create `home-manager/packages/cli-tools.nix`**

Terminal utilities and shell enhancements.

```nix
# CLI tools: terminal utilities, shell enhancements, file tools
{ pkgs, unstable, ... }:

{
  home.packages = with pkgs; [
    bat
    procs
    du-dust
    tealdeer
    delta
    duf
    fd
    ripgrep
    silver-searcher
    unstable.fzf
    mcfly
    bottom
    zoxide
    hexyl
    bingrep
    htop
    gh
    gitui
    jq
    lsof
    ouch
    unzip
    xsel
    xclip
    screen
    reptyr
    croc
    age
    pass
    rage
    nmap
    dig
    scc
    nix-output-monitor
    nix-index
    cachix
    ffmpeg
    imhex
    watson
  ];
}
```

- [ ] **Step 3: Create `home-manager/packages/desktop.nix`**

GUI applications, media, office.

```nix
# Desktop: GUI applications, media, office
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    kitty
    cheese
    spotify
    vlc
    obs-studio
    libreoffice-qt
    zathura
    feh
    nautilus
    deluge
    arandr
    screenkey
    asciinema
    libnotify
    multilockscreen
    paprefs
    pavucontrol
    pasystray
    playerctl
    pulsemixer
    zotero
    insomnia
    godot_4
    distrobox
    virtualbox
  ];
}
```

- [ ] **Step 4: Create `home-manager/packages/k8s.nix`**

Kubernetes and cloud tooling.

```nix
# Kubernetes and cloud tooling
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    kubectl
    kube3d
    k9s
    kubespy
    kdash
    (google-cloud-sdk.withExtraComponents ([ google-cloud-sdk.components.gke-gcloud-auth-plugin ]))
    infra
  ];
}
```

- [ ] **Step 5: Create `home-manager/packages/academic.nix`**

Proof assistants, theorem provers, LaTeX, formal methods.

```nix
# Academic: proof assistants, theorem provers, LaTeX, formal methods
{ pkgs, ... }:

let
  z3-4-12-5 = pkgs.z3.overrideAttrs (old: rec {
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
  home.packages = with pkgs; [
    texlive.combined.scheme-full
    tikzit
    racket
    elan
    z3-4-12-5
    isabelle
    tlaplusToolbox
    (agda.withPackages (ps: [ ps.standard-library ]))
    (aspellWithDicts (ds: with ds; [ en en-computers en-science ]))
    verible
    verilator
    leetcode-cli
  ];
}
```

- [ ] **Step 6: Create `home-manager/packages/default.nix`**

Imports all package groups.

```nix
[
  ./dev-tools.nix
  ./cli-tools.nix
  ./desktop.nix
  ./k8s.nix
  ./academic.nix
]
```

- [ ] **Step 7: Update `home-manager/home.nix`**

Remove the inline `home.packages` block and the `z3-4-12-2` let binding. Add `./packages` to imports.

The new file should be:

```nix
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
```

- [ ] **Step 8: Commit**

```bash
git add home-manager/packages/ home-manager/home.nix
git commit -m "refactor: split home-manager packages into grouped files"
```

---

### Task 3: Update flake.nix and remove dead files

**Files:**
- Modify: `flake.nix`
- Delete: `nixos/` (entire directory)
- Delete: `modules/nixos/default.nix`
- Delete: `modules/home-manager/default.nix`
- Delete: `pkgs/default.nix`
- Delete: `nixpkgs.nix`
- Delete: `shell.nix`

- [ ] **Step 1: Update `flake.nix`**

Point nixosConfigurations to new host paths. Remove nixosModules, homeManagerModules, packages, and devShells exports (all empty/dead). Remove shell.nix and nixpkgs.nix references. Clean up comments.

```nix
{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-colors.url = "github:misterio77/nix-colors";

    attic.url = "github:zhaofengli/attic";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nix-colors, ... }@inputs:
    let
      inherit (self) outputs;
    in
    {
      overlays = import ./overlays { inherit inputs; };

      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./hosts/nixos
          ];
        };
        vb-100 = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./hosts/vb-100
          ];
        };
      };

      homeConfigurations = {
        "isithas@nixos" =
          let
            system = "x86_64-linux";
            pkgs = import nixpkgs { inherit system; };
            unstable = import nixpkgs-unstable { inherit system; };
          in
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = { inherit inputs outputs unstable; };
            modules = [
              ./home-manager/home.nix
            ];
          };
        "isithas@vb-100" =
          let
            system = "x86_64-linux";
            pkgs = import nixpkgs { inherit system; };
            unstable = import nixpkgs-unstable { inherit system; };
          in
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = { inherit inputs outputs unstable; };
            modules = [
              ./home-manager/home.nix
            ];
          };
      };
    };
}
```

Note: The `vb-100` homeConfiguration was missing `unstable` in extraSpecialArgs. This is fixed above so both hosts get the same treatment.

- [ ] **Step 2: Delete old files**

```bash
rm -rf nixos/
rm -rf modules/
rm -rf pkgs/
rm nixpkgs.nix
rm shell.nix
```

- [ ] **Step 3: Verify flake evaluates**

```bash
nix flake check --no-build 2>&1 | head -20
```

If there are eval errors, fix them before committing.

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "refactor: update flake.nix, remove dead modules and legacy files"
```

---

### Task 4: Verify the full configuration evaluates

- [ ] **Step 1: Check nixos config evaluates for both hosts**

```bash
nix eval .#nixosConfigurations.nixos.config.system.build.toplevel --no-build 2>&1 | head -5
nix eval .#nixosConfigurations.vb-100.config.system.build.toplevel --no-build 2>&1 | head -5
```

- [ ] **Step 2: Check home-manager config evaluates**

```bash
nix eval .#homeConfigurations."isithas@nixos".activationPackage --no-build 2>&1 | head -5
```

- [ ] **Step 3: Fix any evaluation errors found**

Address issues and amend or create a fix commit.

- [ ] **Step 4: Final commit if fixes were needed**

```bash
git add -A
git commit -m "fix: resolve evaluation errors from reorganization"
```
