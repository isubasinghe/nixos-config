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
      eval $(${pkgs.zoxide}/bin/zoxide init zsh)
      path+=($HOME/.cargo/bin)
      alias v="nvim"
      alias pf="fzf --preview='bat --style numbers,changes --color=always {}' --bind shift-up:preview-page-up,shift-down:preview-page-down"
      pfzf() {
        local result=$(fzf --preview='bat --style numbers,changes --color=always {}' --bind shift-up:preview-page-up,shift-down:preview-page-down)
        [ -n "$result" ] && nvim -- "$result"
      }
      alias t="tmux"
      alias ta="t a -t"
      alias tls="t ls"
      alias tn="t new -t"
    '';
  };
}
