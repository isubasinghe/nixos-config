{pkgs, config,...}:
{
  home.packages = [pkgs.neovim];
  home.file."${config.xdg.configHome}/nvim" = {
    source = ./nvim;
    recursive = true;
  };
}
