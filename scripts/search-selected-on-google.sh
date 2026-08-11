#!/bin/bash

# Required parameters:
# @vicinae.schemaVersion 1
# @vicinae.title Search Selected Text on Google
# @vicinae.mode silent

# Save and restore the clipboard exactly, including trailing newlines.
clipboard_backup=$(mktemp "${TMPDIR:-/tmp}/vicinae-clipboard.XXXXXX")
trap 'pbcopy < "$clipboard_backup"; rm -f "$clipboard_backup"' EXIT
pbpaste > "$clipboard_backup"

# Copy selected text
if ! osascript -e 'tell application "System Events" to keystroke "c" using command down'; then
    echo "Could not read the selected text"
    exit 1
fi
sleep 0.3

# Get clipboard content
selected_text=$(pbpaste)

# Remove accidental whitespace around the selection.
selected_text="${selected_text#"${selected_text%%[![:space:]]*}"}"
selected_text="${selected_text%"${selected_text##*[![:space:]]}"}"

if [ -z "$selected_text" ]; then
    echo "No selected text found"
    exit 0
fi

# Open URLs directly; search everything else on Google.
if [[ "$selected_text" =~ ^https?://[^[:space:]]+$ ]] || \
   [[ "$selected_text" =~ ^www\.[^[:space:]]+$ ]] || \
   [[ "$selected_text" =~ ^([[:alnum:]-]+\.)+[[:alpha:]]{2,}(/[^[:space:]]*)?$ ]]; then
  url="$selected_text"
  if [[ "$url" != *://* ]]; then
    url="https://$url"
  fi

  if open "$url"; then
    echo "Opened selected link"
  else
    echo "Could not open selected link"
    exit 1
  fi
else
  search_url="https://www.google.com/search?q=$(ruby -e 'require "open-uri"; puts URI.encode_www_form_component(STDIN.read)' <<< "$selected_text")"
  if open "$search_url"; then
    echo "Searched Google for selected text"
  else
    echo "Could not open Google"
    exit 1
  fi
fi
