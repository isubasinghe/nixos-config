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
        "fzf"
        "gh"
        "node"
        "rust"
      ];
    };
    initContent = ''
      eval $(${pkgs.mcfly}/bin/mcfly init zsh)
      eval $(${pkgs.zoxide}/bin/zoxide init zsh)
      path+=($HOME/.cargo/bin)
      alias v="nvim"
      alias cat="bat"
      alias pf="fzf --preview='bat --style numbers,changes --color=always {}' --bind shift-up:preview-page-up,shift-down:preview-page-down"
      pfzf() {
        local result=$(fzf --preview='bat --style numbers,changes --color=always {}' --bind shift-up:preview-page-up,shift-down:preview-page-down)
        [ -n "$result" ] && nvim -- "$result"
      }
      dfzf() {
        local search='docsearch search --tsv -n 50 -- {q} 2>/dev/null || true'
        local result=$(fzf --disabled --delimiter='\t' --with-nth=3.. \
          --bind "start:reload:$search" --bind "change:reload:$search" \
          --preview='docsearch show {1} | bat --language md --style numbers --color=always' \
          --bind shift-up:preview-page-up,shift-down:preview-page-down)
        [ -n "$result" ] || return
        local id=''${result%%$'\t'*} location=''${result#*$'\t'}
        location=''${location%%$'\t'*}
        case $location in
          http://*|https://*) xdg-open "$location" ;;
          *) docsearch show "$id" | nvim -R -c 'set filetype=markdown' - ;;
        esac
      }
      alias t="tmux"
      alias ta="t a -t"
      alias tls="t ls"
      alias tn="t new -t"
    '';
  };
}
