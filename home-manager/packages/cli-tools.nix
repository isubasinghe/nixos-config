# CLI tools: terminal utilities, shell enhancements, file tools
{ pkgs, unstable, inputs, ... }:

{
  home.packages = with pkgs; [
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex
    inputs.ortie.packages.${pkgs.stdenv.hostPlatform.system}.default
    opencode
    github-copilot-cli
    bat
    procs
    dust
    tealdeer
    delta
    duf
    fd
    gcal
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
    docker-client
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
    yazi
    newsboat
    libqalculate
    khal
    vdirsyncer
    unstable.himalaya
  ];

  xdg.configFile."khal/config".text = ''
    [calendars]

    [[personal]]
    path = ~/.local/share/calendars/personal
    type = calendar

    [default]
    default_calendar = personal
  '';

  xdg.dataFile."calendars/personal/.keep".text = "";

  xdg.configFile."newsboat/urls".text = ''
    # Add RSS feeds here, one URL per line, e.g.
    # https://example.com/feed.xml
  '';
}
