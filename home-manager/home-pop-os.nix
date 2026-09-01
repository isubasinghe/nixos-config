# Home-manager configuration for Pop!_OS (standalone, no X11/WM modules)
{ pkgs, ... }:

{
  imports = [
    ./profiles/common.nix
    ./programs/zsh
    ./programs/starship
    ./programs/tmux
    ./programs/zoxide
    ./programs/neovim
    ./programs/remind
    ./programs/wezterm
    ./programs/ghostty
    ./packages/cli-tools.nix
    ./packages/dev-tools.nix
    ./packages/k8s.nix
    ./packages/academic.nix
  ];

  home = {
    username = "isubasinghe";
    homeDirectory = "/home/isubasinghe";
  };

  dconf.settings."org/gnome/desktop/default-applications/terminal" = {
    exec = "ghostty";
    exec-arg = "";
  };

  home.stateVersion = "24.05";
}
