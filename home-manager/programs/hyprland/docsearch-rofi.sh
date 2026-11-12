# A rofi script mode for docsearch.
#
# Use: rofi -modi "docs:docsearch-rofi" -show docs
#
# 1. Type a query. Press Enter. The script shows the results.
# 2. Move to a result. Press Enter. The script opens the document.
#    A GitHub file or a web page opens in the browser. A local file opens in
#    the default program. For other locations, the script copies the location.
# 3. To search again, type a new query and press Ctrl+Enter.
#
# rofi calls the script with ROFI_RETV=0 at the start, with ROFI_RETV=2 and the
# typed text as $1 for a new query, and with ROFI_RETV=1 and ROFI_INFO set to
# the location for a selected result.

# docsearch is in the cargo directory. A Hyprland session does not have it in PATH.
export PATH="$HOME/.cargo/bin:$PATH"

MAX_RESULTS=30

header() {
  printf '\0prompt\x1fdocs\n'
  printf '\0markup-rows\x1ftrue\n'
}

message() {
  printf '\0message\x1f%s\n' "$1"
}

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
  # rofi waits until the script closes its output. Start the program detached.
  setsid -f xdg-open "$url" >/dev/null 2>&1 || true
}

search() {
  local query=$1 json errors warnings count
  errors=$(mktemp)
  trap 'rm -f "$errors"' RETURN
  header
  if ! json=$(docsearch search --json -n "$MAX_RESULTS" -- "$query" 2>"$errors"); then
    message "<span foreground='#ff6c6b'>$(escape "$(sed -e 's/^error: //' "$errors" | head -n 3)")</span>"
    return 0
  fi
  warnings=$(sed -n 's/^warning: //p' "$errors" | head -n 2)
  count=$(jq 'length' <<<"$json")
  if [[ $count -eq 0 ]]; then
    message "No results for <b>$(escape "$query")</b>. Type a new query and press Ctrl+Enter."
    return 0
  fi
  local text
  text="$count results for <b>$(escape "$query")</b>. Enter opens. Ctrl+Enter searches again."
  if [[ -n $warnings ]]; then
    text+=$'\n'"<i>$(escape "$warnings")</i>"
  fi
  message "$text"
  jq -r '
    def esc: gsub("&";"&amp;") | gsub("<";"&lt;") | gsub(">";"&gt;");
    .[] | "<b>\(.title | esc)</b>  <small>[\(.category | esc)]  \(.location | esc)</small>\u0000info\u001f\(.location)"
  ' <<<"$json"
}

case "${ROFI_RETV:-0}" in
  1) open_location "${ROFI_INFO:-}" ;;
  2) search "${1:-}" ;;
  *)
    header
    message 'Type a query and press Enter. Syntax: "exact phrase", AND, OR, NOT, title:word, word~1'
    ;;
esac
