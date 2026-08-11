#!/bin/bash

# @vicinae.schemaVersion 1
# @vicinae.title Copy Selected Finder Path
# @vicinae.mode silent
# @vicinae.keywords ["path", "file path", "finder"]

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

printf '%s\n' "$paths" | pbcopy

count=$(printf '%s\n' "$paths" | awk 'NF { count++ } END { print count + 0 }')
if [ "$count" -eq 1 ]; then
    echo "Copied 1 Finder path"
else
    echo "Copied $count Finder paths"
fi
