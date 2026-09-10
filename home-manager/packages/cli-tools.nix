# CLI tools: terminal utilities, shell enhancements, file tools
{ pkgs, unstable, inputs, ... }:

{
  home.packages = with pkgs; [
    inputs.ortie.packages.${pkgs.stdenv.hostPlatform.system}.default
    opencode
    github-copilot-cli
    bat
    procs
    dust
    tealdeer
    delta
    duf
    fd
    gcal
    ripgrep
    silver-searcher
    unstable.fzf
    mcfly
    bottom
    zoxide
    hexyl
    bingrep
    htop
    gh
    gitui
    docker-client
    jq
    lsof
    ouch
    unzip
    xsel
    xclip
    screen
    reptyr
    croc
    age
    pass
    rage
    nmap
    dig
    scc
    nix-output-monitor
    nix-index
    cachix
    ffmpeg
    imhex
    watson
    yazi
    newsboat
    neomutt
    chafa
    # Terminal-aware image rendering for neomutt: chafa auto-detects from $TERM
    # (usually xterm-256color, even in capable terminals), so pick the graphics
    # protocol from $TERM_PROGRAM instead. Ghostty speaks kitty, WezTerm iterm.
    (writeShellScriptBin "hm-img" ''
      fmt=symbols
      case "''${TERM_PROGRAM:-}" in
        ghostty) fmt=kitty ;;
        WezTerm) fmt=iterm ;;
      esac
      pass=()
      [ -n "''${TMUX:-}" ] && pass=(--passthrough tmux)
      exec chafa -f "$fmt" "''${pass[@]}" "$@"
    '')
    libqalculate
    khal
    vdirsyncer
    unstable.himalaya
    (writeShellScriptBin "hm-mail" ''
      set -euo pipefail
      box="''${1:-INBOX}"
      export box
      sel=$(himalaya envelope list -a sqc -m "$box" -s 50 --json \
        | jq -r '.envelopes[] | "\(.id)\t\(.date[0:16]) \(.from[0].name // .from[0].email) | \(.subject)"' \
        | fzf --delimiter=$'\t' --with-nth=2.. --prompt="sqc/$box> " \
          --preview='id=$(echo {} | cut -f1); himalaya message read -a sqc -m "$box" "$id" | head -n 60' \
          --preview-window=right:60%:wrap || true)
      [ -z "''${sel:-}" ] && exit 0
      id=$(echo "$sel" | cut -f1)
      himalaya message read -a sqc -m "$box" "$id" | "''${PAGER:-less}"
    '')
    (writeShellScriptBin "hm-sync" ''
      set -euo pipefail
      root="''${HM_MAILDIR:-$HOME/Mail/sqc}"
      state="''${XDG_STATE_HOME:-$HOME/.local/share}/hm-sync/seen"
      mkdir -p "$root" "$state"
      for box in INBOX SentItems; do
        dir="$root/$box"
        mkdir -p "$dir"/cur "$dir"/new "$dir"/tmp
        himalaya envelope list -a sqc -m "$box" -s 100 --json \
          | jq -r '.envelopes[] | "\(.id)\t\([.flags[].iana // empty] | join(","))"' \
          | while IFS=$'\t' read -r id flags; do
            safe=$(echo "$id" | tr -c 'A-Za-z0-9' '_')
            [ -f "$state/$box-$safe" ] && continue
            tmp=$(mktemp "$dir/tmp/sync.XXXXXX.eml")
            if himalaya msgraph message get -a sqc "$id" --raw > "$tmp" 2>/dev/null; then
              base=$(date +%s).$RANDOM.$HOSTNAME
              case ",$flags," in
                *,seen,*) mv "$tmp" "$dir/cur/$base:2,S" ;;
                *) mv "$tmp" "$dir/new/$base" ;;
              esac
              touch "$state/$box-$safe"
            else
              rm -f "$tmp"
            fi
          done
      done
      echo "synced to $root"
    '')
  ];

  xdg.configFile."khal/config".text = ''
    [calendars]

    [[personal]]
    path = ~/.local/share/calendars/personal
    type = calendar

    [default]
    default_calendar = personal
  '';

  xdg.dataFile."calendars/personal/.keep".text = "";

  xdg.configFile."newsboat/urls".text = ''
    https://news.ycombinator.com/rss
    https://lobste.rs/rss
    https://planet.haskell.org/atom.xml
    https://this-week-in-rust.org/rss.xml
    https://planet.nixos.org/atom.xml
    https://discourse.nixos.org/latest.rss
    https://export.arxiv.org/rss/quant-ph
    https://www.quantamagazine.org/feed/
    https://muratbuffalo.blogspot.com/feeds/posts/default
    https://semantic-domain.blogspot.com/feeds/posts/default
    https://scottaaronson.blog/?feed=rss2
    https://golem.ph.utexas.edu/category/atom10.xml
    https://existentialtype.wordpress.com/feed/
    https://homotopytypetheory.org/feed/
    https://blog.llvm.org/index.xml
    https://eli.thegreenplace.net/feeds/all.atom.xml
    https://www.osnews.com/feed/
    https://lwn.net/headlines/rss
    https://github.com/Z3Prover/z3/releases.atom
    https://github.com/seL4/seL4/releases.atom
    https://microkerneldude.org/feed/
    https://maskray.me/blog/atom.xml
    https://algassert.com/feed
    https://www.ralfj.de/blog/feed.xml
    https://www.hillelwayne.com/index.xml
    https://blog.regehr.org/feed
    https://matklad.github.io/feed.xml
    https://danluu.com/atom.xml
    https://easyperf.net/feed.xml
    http://www.brendangregg.com/blog/rss.xml
    https://blog.sigplan.org/feed/
    https://fasterthanli.me/index.xml
    https://blog.janestreet.com/feed.xml
    https://zipcpu.com/feed.xml
    https://www.pvk.ca/atom.xml
    https://nullprogram.com/feed/
    https://bernsteinbear.com/feed.xml
    https://chipsandcheese.com/feed/
    https://blog.trailofbits.com/feed/
    https://www.tweag.io/rss.xml
    https://www.well-typed.com/blog/atom.xml
    https://scattered-thoughts.net/feed.xml
    https://bcantrill.dtrace.org/index.xml
    https://smallcultfollowing.com/babysteps/atom.xml
    https://without.boats/index.xml
    https://preshing.com/feed
  '';

  # Local-only Maildir reader for the Outlook mirror at ~/Mail/sqc
  # (populated by `hm-sync`). No network, no auth. Sending is intentionally
  # unconfigured - send via `himalaya message compose --send` (Graph).
  xdg.configFile."neomutt/neomuttrc".text = ''
    set mbox_type = Maildir
    set folder = "~/Mail/sqc"
    set spoolfile = "+INBOX"
    set record = "+SentItems"
    mailboxes +INBOX +SentItems
    set editor = "nvim"
    set sidebar_visible = yes
    set sidebar_width = 24
    set sidebar_format = "%B%?F? [%F]?%* %?N?%N/? %S"
    bind index,pager B sidebar-toggle-visible
    auto_view text/html
    auto_view application/pdf
    alternative_order text/plain text/enriched text/html
  '';

  home.file.".mailcap".text = ''
    text/html; pandoc -f html -t plain %s; copiousoutput; description=HTML Text
    image/*; feh --scale-down %s; description=Image
    application/pdf; pdftotext -layout %s -; copiousoutput; description=PDF Text
    application/pdf; zathura %s; description=PDF
  '';

  # Pull Outlook -> ~/Mail/sqc every 5 min. Uses the cached gpg passphrase,
  # so unlock `pass` once in a terminal after login (any `hm-sync` run).
  systemd.user.services.hm-sync = {
    Unit.Description = "Sync Outlook mail to local Maildir";
    Service = {
      Type = "oneshot";
      ExecStart = "%h/.nix-profile/bin/hm-sync";
    };
  };

  systemd.user.timers.hm-sync = {
    Unit.Description = "Sync Outlook mail periodically";
    Timer = {
      OnBootSec = "2min";
      OnUnitActiveSec = "5min";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
