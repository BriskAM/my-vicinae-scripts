#!/bin/bash

# Required parameters:
# @vicinae.schemaVersion 1
# @vicinae.title Open Downloads
# @vicinae.mode silent

if open "$HOME/Downloads"; then
    echo "Opened Downloads"
else
    echo "Could not open Downloads"
    exit 1
fi
