#!/bin/bash

# Required parameters:
# @vicinae.schemaVersion 1
# @vicinae.title Open Second Last Download
# @vicinae.mode silent

# Find the second most recently modified file in Downloads and open it
second_last=$(ls -tA "$HOME/Downloads" 2>/dev/null | sed -n '2p')

if [ -n "$second_last" ]; then
    if open "$HOME/Downloads/$second_last"; then
        echo "Opened $second_last"
    else
        echo "Could not open $second_last"
        exit 1
    fi
else
    echo "No second download found"
fi
