#!/bin/bash

# @vicinae.schemaVersion 1
# @vicinae.title Tag Selected Red
# @vicinae.mode silent
# @vicinae.keywords ["finder", "tag", "red", "label"]

set -euo pipefail

label_index=2

result=$(osascript - "$label_index" <<'APPLESCRIPT'
on run argv
    set labelIndex to item 1 of argv as integer
    tell application "Finder"
        set selectedItems to selection
        if (count of selectedItems) is 0 then return "NO_SELECTION"
        set removedCount to 0
        repeat with selectedItem in selectedItems
            if (label index of selectedItem) is labelIndex then
                set label index of selectedItem to 0
                set removedCount to removedCount + 1
            else
                set label index of selectedItem to labelIndex
            end if
        end repeat
        if removedCount is (count of selectedItems) then return "REMOVED"
        return "MARKED"
    end tell
end run
APPLESCRIPT
)

if [ "$result" = "NO_SELECTION" ]; then
    echo "No file or folder selected in Finder"
else
    if [ "$result" = "REMOVED" ]; then echo "Removed red tag"; else echo "Marked selected item(s) red"; fi
fi
