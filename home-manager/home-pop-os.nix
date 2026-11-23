# Home-manager configuration for Pop!_OS (standalone, no X11/WM modules)
{ config, pkgs, inputs, lib, ... }:

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

  targets.genericLinux.enable = true;
  targets.genericLinux.nixGL = {
    packages = inputs.nixgl.packages;
    defaultWrapper = "mesa";
    offloadWrapper = "nvidiaPrime";
    installScripts = [ "mesa" ];
    vulkan.enable = true;
  };

  home = {
    username = "isubasinghe";
    homeDirectory = "/home/isubasinghe";
    packages = [
      (config.lib.nixGL.wrap pkgs.gnome-disk-utility)
    ];
  };

  dconf.settings."org/gnome/desktop/default-applications/terminal" = {
    exec = "ghostty";
    exec-arg = "";
  };

  # Override the Flatpak launcher with the Home Manager build. Older Flatpak
  # releases have a scroll-margin bug and use a separate config directory.
  xdg.desktopEntries."org.wezfurlong.wezterm" = {
    name = "WezTerm";
    comment = "Wez's Terminal Emulator";
    exec = "${config.programs.wezterm.package}/bin/wezterm start --always-new-process --cwd .";
    icon = "org.wezfurlong.wezterm";
    terminal = false;
    categories = [ "System" "TerminalEmulator" "Utility" ];
    settings.StartupWMClass = "org.wezfurlong.wezterm";
  };

  programs.zsh.initContent = lib.mkAfter ''
    export GOPATH="/home/isubasinghe/go"
    export PATH="$GOPATH/bin:$PATH"
  '';

  home.stateVersion = "24.05";
}
