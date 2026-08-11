#!/bin/bash

# Required parameters:
# @vicinae.schemaVersion 1
# @vicinae.title Open Last Download
# @vicinae.mode silent

# Find the most recently modified regular, non-hidden file in Downloads.
downloads_dir="$HOME/Downloads"
last_download=""
last_mtime=0

for candidate in "$downloads_dir"/* "$downloads_dir"/.[!.]* "$downloads_dir"/..?*; do
    [ -f "$candidate" ] || continue

    filename=$(basename "$candidate")
    case "$filename" in
        .*) continue ;;
    esac

    mtime=$(stat -f '%m' "$candidate" 2>/dev/null) || continue
    if [ "$mtime" -gt "$last_mtime" ]; then
        last_mtime="$mtime"
        last_download="$candidate"
    fi
done

if [ -n "$last_download" ]; then
    if open "$last_download"; then
        echo "Opened $(basename "$last_download")"
    else
        echo "Could not open $(basename "$last_download")"
        exit 1
    fi
else
    echo "No downloads found"
fi
