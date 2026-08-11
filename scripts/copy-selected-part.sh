#!/bin/bash

# Required parameters:
# @vicinae.schemaVersion 1
# @vicinae.title Copy selected part
# @vicinae.mode silent


if screencapture -i -c -x; then
    echo "Selection copied to clipboard"
else
    echo "Screenshot cancelled"
fi
