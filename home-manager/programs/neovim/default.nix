{pkgs, unstable, config,...}:
{
  home.packages = [unstable.neovim];
  home.file."${config.xdg.configHome}/nvim" = {
    source = ./nvim;
    recursive = true;
  };
}
