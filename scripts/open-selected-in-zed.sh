#!/bin/bash

# @vicinae.schemaVersion 1
# @vicinae.title Open Selected in Zed
# @vicinae.mode silent
# @vicinae.keywords ["zed", "editor", "finder"]

set -euo pipefail

if ! paths=$(osascript <<'APPLESCRIPT'
tell application "Finder"
    set selectedItems to selection
    if (count selectedItems) is 0 then return ""

    set output to ""
    repeat with itemRef in selectedItems
        set output to output & (POSIX path of (itemRef as alias)) & linefeed
    end repeat

    return output
end tell
APPLESCRIPT
); then
    echo "Could not read Finder selection"
    exit 1
fi

if [ -z "$paths" ]; then
    echo "No Finder items selected"
    exit 0
fi

opened=0
while IFS= read -r path; do
    [ -n "$path" ] || continue
    if open -a "Zed" "$path"; then
        opened=$((opened + 1))
    else
        echo "Could not open item in Zed"
        exit 1
    fi
done <<< "$paths"

if [ "$opened" -eq 1 ]; then
    echo "Opened 1 item in Zed"
else
    echo "Opened $opened items in Zed"
fi
