{pkgs, ...}: 
{
  programs.tmux = {
    enable = true;
    shell="${pkgs.zsh}/bin/zsh";
    plugins = with pkgs; [
      tmuxPlugins.tmux-thumbs
      tmuxPlugins.tmux-fzf
      tmuxPlugins.tmux-colors-solarized
      tmuxPlugins.cpu
      tmuxPlugins.extrakto
      tmuxPlugins.copycat
      tmuxPlugins.yank
    ];
  };
}
