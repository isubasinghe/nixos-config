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
