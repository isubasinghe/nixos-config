{ config, pkgs, unstable, ... }:

let
  inherit (config) colorscheme;
  inherit (colorscheme) palette;
in
{
  programs.wezterm = {
    enable = true;
    package = config.lib.nixGL.wrap pkgs.wezterm;
    colorSchemes = {
      "${colorscheme.slug}" = {
        foreground = "#${palette.base04}";
        background = "#${palette.base00}";

        ansi = [
          "#${palette.base01}"
          "#${palette.base08}"
          "#${palette.base0B}"
          "#${palette.base0A}"
          "#${palette.base0D}"
          "#${palette.base0F}"
          "#${palette.base0C}"
          "#${palette.base06}"
        ];
        brights = [
          "#${palette.base00}"
          "#${palette.base09}"
          "#${palette.base02}"
          "#${palette.base03}"
          "#${palette.base04}"
          "#${palette.base0E}"
          "#${palette.base05}"
          "#${palette.base07}"
        ];

        cursor_bg = "#${palette.base04}";
        cursor_border = "#${palette.base04}";
        cursor_fg = "#${palette.base01}";
        selection_fg = "#${palette.base00}";
        selection_bg = "#${palette.base01}";
      };
    };
    extraConfig = /* lua */ ''
      return {
        font_size = 12.0,
        color_scheme = "${colorscheme.slug}",
        hide_tab_bar_if_only_one_tab = true,
        window_close_confirmation = "NeverPrompt",
        set_environment_variables = {
          TERM = 'wezterm',
        },
        default_prog = { "${pkgs.zsh}/bin/zsh" },
        front_end = "WebGpu",
      }
    '';
  };
}
