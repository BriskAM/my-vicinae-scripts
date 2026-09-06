#!/bin/bash

# @vicinae.schemaVersion 1
# @vicinae.title Tag Selected Green
# @vicinae.mode compact
# @vicinae.keywords ["finder", "tag", "green", "label"]

set -euo pipefail

label_index=2

result=$(osascript - "$label_index" <<'APPLESCRIPT'
on run argv
    set labelIndex to item 1 of argv as integer
    tell application "Finder"
        set selectedItems to selection
        if (count of selectedItems) is 0 then return "NO_SELECTION"
        repeat with selectedItem in selectedItems
            set label index of selectedItem to labelIndex
        end repeat
        return (count of selectedItems) as text
    end tell
end run
APPLESCRIPT
)

if [ "$result" = "NO_SELECTION" ]; then
    echo "No file or folder selected in Finder"
else
    echo "Marked $result item(s) green"
fi
