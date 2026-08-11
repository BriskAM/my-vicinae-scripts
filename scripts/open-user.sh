#!/bin/bash

# Required parameters:
# @vicinae.schemaVersion 1
# @vicinae.title Open User
# @vicinae.mode silent

if open "$HOME"; then
    echo "Opened home folder"
else
    echo "Could not open home folder"
    exit 1
fi
