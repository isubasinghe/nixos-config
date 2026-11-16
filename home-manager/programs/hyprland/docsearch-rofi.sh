# A rofi-blocks program for docsearch. It searches again after each keystroke.
#
# Use: rofi -modi blocks -show blocks -blocks-wrap docsearch-rofi
#
# 1. Type a query. The results change while you type.
# 2. Move to a result. Press Enter. The program opens the document.
#    A GitHub file or a web page opens in the browser. A local file opens in
#    the default program. For other locations, the program copies the location.
#
# rofi-blocks starts this program one time. The program writes one JSON object
# on each output line to set the rofi content. rofi-blocks writes one JSON
# event on each input line: "input change" has the typed text in .value, and
# "select entry" has the location of the result in .data. rofi closes when
# this program stops.

# docsearch is in the cargo directory. A Hyprland session does not have it in PATH.
export PATH="$HOME/.cargo/bin:$PATH"

MAX_RESULTS=30
HELP='Type a query. Syntax: "exact phrase", AND, OR, NOT, title:word, word~1'

errors=$(mktemp)
trap 'rm -f "$errors"' EXIT

# Escape text for Pango markup.
escape() {
  jq -Rr 'gsub("&";"&amp;") | gsub("<";"&lt;") | gsub(">";"&gt;")' <<<"$1"
}

open_location() {
  local location=$1 url
  if [[ $location =~ ^https?:// ]]; then
    url=$location
  elif [[ $location =~ ^git@github\.com:(.+)\.git@([^:]+):(.+)$ ]]; then
    url="https://github.com/${BASH_REMATCH[1]}/blob/${BASH_REMATCH[2]}/${BASH_REMATCH[3]}"
  elif [[ -e $location ]]; then
    url=$location
  else
    printf '%s' "$location" | wl-copy >/dev/null 2>&1 || true
    return 0
  fi
  # Start the program detached, because rofi closes when this program stops.
  setsid -f xdg-open "$url" >/dev/null 2>&1 || true
}

search() {
  local query=$1 json warnings count text
  if [[ -z ${query//[[:space:]]/} ]]; then
    jq -cn --arg message "$HELP" '{message: $message, lines: []}'
    return 0
  fi
  if ! json=$(docsearch search --json -n "$MAX_RESULTS" -- "$query" 2>"$errors"); then
    # A query can be incorrect while you type it, for example an open quote.
    # Show the error and keep the last results.
    text="<span foreground='#ff6c6b'>$(escape "$(sed -e 's/^error: //' "$errors" | head -n 3)")</span>"
    jq -cn --arg message "$text" '{message: $message}'
    return 0
  fi
  warnings=$(sed -n 's/^warning: //p' "$errors" | head -n 2)
  count=$(jq 'length' <<<"$json")
  if [[ $count -eq 0 ]]; then
    text="No results for <b>$(escape "$query")</b>."
  else
    text="$count results for <b>$(escape "$query")</b>. Enter opens."
  fi
  if [[ -n $warnings ]]; then
    text+=$'\n'"<i>$(escape "$warnings")</i>"
  fi
  jq -c --arg message "$text" '
    def esc: gsub("&";"&amp;") | gsub("<";"&lt;") | gsub(">";"&gt;");
    {
      message: $message,
      lines: map({
        text: "<b>\(.title | esc)</b>  <small>[\(.category | esc)]  \(.location | esc)</small>",
        markup: true,
        data: .location
      })
    }
  ' <<<"$json"
}

# "input action": "send" stops the rofi filter and sends each change of the
# typed text to this program.
jq -cn --arg message "$HELP" \
  '{prompt: "docs", "input action": "send", message: $message, lines: []}'

while IFS= read -r event; do
  name=$(jq -r '.name // ""' <<<"$event" 2>/dev/null) || continue
  case "$name" in
    "input change")
      search "$(jq -r '.value // ""' <<<"$event")"
      ;;
    "select entry")
      open_location "$(jq -r '.data // ""' <<<"$event")"
      exit 0
      ;;
  esac
done
