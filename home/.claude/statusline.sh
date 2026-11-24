#!/usr/bin/env bash
# Prints: <used>k / <window>k (<pct of window>%), colored by absolute usage.
in=$(cat)
used=$(jq -r '(.context_window.current_usage // {})
  | ((.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0))' <<<"$in")
size=$(jq -r '.context_window.context_window_size // 0' <<<"$in")

warn=100000   # yellow
limit=150000  # red: your smart-zone ceiling
if   [ "$used" -ge "$limit" ]; then c=31
elif [ "$used" -ge "$warn" ];  then c=33
else c=32; fi

if [ "$size" -gt 0 ]; then
  printf '\033[%sm%dk / %dk (%d%%)\033[0m' "$c" $((used/1000)) $((size/1000)) $((used*100/size))
else
  printf '\033[%sm%dk / –\033[0m' "$c" $((used/1000))
fi
