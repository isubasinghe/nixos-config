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
    (writeShellScriptBin "hm-cal-sync" ''
      set -euo pipefail
      root="''${XDG_DATA_HOME:-$HOME/.local/share}/calendars/outlook"
      mkdir -p "$root"
      export HM_CAL_ROOT="$root"
      export GRAPH_TOKEN="$(ortie token show -a sqc)"
      # Window: past 30d .. future 90d (override via HM_CAL_PAST_DAYS / HM_CAL_FUTURE_DAYS)
      export HM_CAL_PAST_DAYS="''${HM_CAL_PAST_DAYS:-30}"
      export HM_CAL_FUTURE_DAYS="''${HM_CAL_FUTURE_DAYS:-90}"
      python3 - <<'PYEOF'
      import datetime, hashlib, json, os, pathlib, sys, urllib.parse, urllib.request
      from zoneinfo import ZoneInfo

      root = pathlib.Path(os.environ["HM_CAL_ROOT"])
      token = os.environ["GRAPH_TOKEN"]
      past = int(os.environ.get("HM_CAL_PAST_DAYS", "30"))
      future = int(os.environ.get("HM_CAL_FUTURE_DAYS", "90"))
      now = datetime.datetime.now(datetime.timezone.utc)
      start = (now - datetime.timedelta(days=past)).strftime("%Y-%m-%dT%H:%M:%SZ")
      end = (now + datetime.timedelta(days=future)).strftime("%Y-%m-%dT%H:%M:%SZ")
      select = "id,subject,bodyPreview,start,end,location,isAllDay,isCancelled,showAs,onlineMeeting,type"
      params = {"startDateTime": start, "endDateTime": end, "$top": "100", "$select": select}
      url = "https://graph.microsoft.com/v1.0/me/calendarView?" + urllib.parse.urlencode(params, safe="$,")
      events = []
      while url:
          req = urllib.request.Request(url, headers={"Authorization": "Bearer " + token, "Accept": "application/json"})
          try:
              with urllib.request.urlopen(req, timeout=30) as r:
                  data = json.load(r)
          except Exception as e:
              print("graph fetch failed: " + str(e), file=sys.stderr)
              sys.exit(1)
          events.extend(data.get("value", []))
          url = data.get("@odata.nextLink")

      def esc(s):
          return (s or "").replace("\\", "\\\\").replace(";", "\\;").replace(",", "\\,").replace("\r", "").replace("\n", "\\n")

      def parse_dt(d):
          # d = {"dateTime": "2026-09-07T11:30:00.0000000", "timeZone": "UTC" | IANA}
          s = d.get("dateTime", "")
          tzname = d.get("timeZone", "UTC") or "UTC"
          # python fromisoformat handles max 6 fractional digits; truncate extras
          if "." in s:
              head, frac = s.split(".", 1)
              digits = "".join(ch for ch in frac if ch.isdigit())[:6]
              s = head + ("." + digits if digits else "")
          try:
              naive = datetime.datetime.fromisoformat(s)
          except ValueError:
              naive = datetime.datetime.strptime(s[:19], "%Y-%m-%dT%H:%M:%S")
          if tzname.upper() == "UTC":
              tz = datetime.timezone.utc
          else:
              try:
                  tz = ZoneInfo(tzname)
              except Exception:
                  tz = datetime.timezone.utc
          return naive.replace(tzinfo=tz)

      def fmt_utc(dt):
          return dt.astimezone(datetime.timezone.utc).strftime("%Y%m%dT%H%M%SZ")

      # RFC5545: max 75 octets per line, continuation lines start with space
      def foldline(line):
          enc = line.encode("utf-8")
          parts = []
          first = True
          while enc:
              limit = 75 if first else 74
              if len(enc) <= limit:
                  parts.append(enc.decode("utf-8"))
                  break
              cut = limit
              while cut > 0 and (enc[cut] & 0xC0) == 0x80:
                  cut -= 1
              parts.append(enc[:cut].decode("utf-8"))
              enc = b" " + enc[cut:]
              first = False
          return "\r\n".join(parts)

      stamp = now.strftime("%Y%m%dT%H%M%SZ")
      written = set()
      for ev in events:
          eid = ev.get("id", "")
          if not eid:
              continue
          fname = hashlib.sha256(eid.encode()).hexdigest() + ".ics"
          written.add(fname)
          allday = ev.get("isAllDay", False)
          sdt = parse_dt(ev.get("start", {}))
          edt = parse_dt(ev.get("end", {}))
          if allday:
              dtstart = "DTSTART;VALUE=DATE:" + sdt.strftime("%Y%m%d")
              dtend = "DTEND;VALUE=DATE:" + edt.strftime("%Y%m%d")
          else:
              dtstart = "DTSTART:" + fmt_utc(sdt)
              dtend = "DTEND:" + fmt_utc(edt)
          subject = ev.get("subject", "") or "(no title)"
          loc = ((ev.get("location") or {}).get("displayName")) or ""
          desc = ev.get("bodyPreview", "") or ""
          join = ((ev.get("onlineMeeting") or {}).get("joinUrl")) or ""
          if join:
              desc = (desc + "\\nJoin: " + join) if desc else ("Join: " + join)
          lines = [
              "BEGIN:VCALENDAR",
              "VERSION:2.0",
              "PRODID:-//nixos-config//hm-cal-sync//EN",
              "BEGIN:VEVENT",
              "UID:" + eid + "@sqc-graph",
              "DTSTAMP:" + stamp,
              dtstart,
              dtend,
              "SUMMARY:" + esc(subject),
          ]
          if loc:
              lines.append("LOCATION:" + esc(loc))
          if desc:
              lines.append("DESCRIPTION:" + esc(desc))
          if ev.get("isCancelled"):
              lines.append("STATUS:CANCELLED")
          if (ev.get("showAs") or "") == "free":
              lines.append("TRANSP:TRANSPARENT")
          lines += ["END:VEVENT", "END:VCALENDAR", ""]
          content = "\r\n".join(foldline(l) for l in lines)
          (root / fname).write_text(content)
      # prune stale events (cancelled/deleted upstream)
      for p in root.glob("*.ics"):
          if p.name not in written:
              p.unlink()
      print("synced " + str(len(written)) + " events to " + str(root))
      PYEOF
      echo "synced to $root"
    '')
  ];

  xdg.configFile."khal/config".text = ''
    [calendars]

    [[personal]]
    path = ~/.local/share/calendars/personal
    type = calendar

    [[outlook]]
    path = ~/.local/share/calendars/outlook
    type = calendar
    readonly = True

    [default]
    default_calendar = personal
  '';

  xdg.dataFile."calendars/personal/.keep".text = "";
  xdg.dataFile."calendars/outlook/.keep".text = "";

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

  # Pull M365 calendar -> khal vdir every 15 min. Reuses the ortie/sqc token
  # (already has Calendars.Read); needs `pass` unlocked like hm-sync.
  systemd.user.services.hm-cal-sync = {
    Unit.Description = "Sync M365 calendar to khal vdir";
    Service = {
      Type = "oneshot";
      ExecStart = "%h/.nix-profile/bin/hm-cal-sync";
    };
  };

  systemd.user.timers.hm-cal-sync = {
    Unit.Description = "Sync M365 calendar periodically";
    Timer = {
      OnBootSec = "2min";
      OnUnitActiveSec = "15min";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
