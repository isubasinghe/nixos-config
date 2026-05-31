# CLI tools: terminal utilities, shell enhancements, file tools
{ pkgs, unstable, inputs, ... }:

{
  home.packages = with pkgs; [
    inputs.llm-agents.packages.${pkgs.system}.codex
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
