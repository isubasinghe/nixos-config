{ pkgs, ... }: 
{ 
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
        "cp"
        "fd"
        "fzf"
        "gh"
        "node"
        "rust"
      ];
    };
    initExtra = ''
      eval $(${pkgs.mcfly}/bin/mcfly init zsh)
      path+=($HOME/.cargo/bin)
    '';
  };
}
