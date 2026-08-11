#!/bin/bash

# Required parameters:
# @vicinae.schemaVersion 1
# @vicinae.title Open Last Download
# @vicinae.mode silent

# Find the most recently modified file in Downloads and open it
last_download=$(ls -tA "$HOME/Downloads" 2>/dev/null | head -1)

if [ -n "$last_download" ]; then
    if open "$HOME/Downloads/$last_download"; then
        echo "Opened $last_download"
    else
        echo "Could not open $last_download"
        exit 1
    fi
else
    echo "No downloads found"
fi
