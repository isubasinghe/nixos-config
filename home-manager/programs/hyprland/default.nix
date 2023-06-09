{pkgs, lib, ...}: let
  flake-compat = builtins.fetchTarball { 
    url="https://github.com/edolstra/flake-compat/archive/master.tar.gz"; 
    sha256="sha256:1prd9b1xx8c0sfwnyzkspplh30m613j42l1k789s521f4kv4c2z2";
  };

  hyprland = (import flake-compat {
    src = builtins.fetchTarball {
      url = "https://github.com/hyprwm/Hyprland/archive/master.tar.gz";
      sha256 = "sha256:00l3xrdmg9jfk6kcss6jp2szkvniraamqrrwbxv5b7jh8yg53acr";
    };
  }).defaultNix;
in {
  imports = [
    hyprland.homeManagerModules.default
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      bind = SUPER, Return, exec, ${pkgs.wezterm}/bin/wezterm
      bind = SUPER, p, exec, ${pkgs.wofi}/bin/wofi --show=drun
      bind = SUPER, f, exec, ${pkgs.firefox}/bin/firefox
      bind = SUPER, h, movefocus, l
      bind = SUPER, l, movefocus, r
      bind = SUPER_SHIFT, F, fullscreen, 1
      bind = SUPER_SHIFT, X, killactive
      bind = ALT, TAB, cyclenext, none
    '';
  };
}
