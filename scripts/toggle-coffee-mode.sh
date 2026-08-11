#!/bin/bash

# @vicinae.schemaVersion 1
# @vicinae.title Toggle Coffee Mode
# @vicinae.mode silent
# @vicinae.keywords ["coffee", "caffeine", "awake", "prevent sleep"]

set -euo pipefail

support_dir="$HOME/.local/share/vicinae/support"
source_file="$support_dir/VicinaeCoffeeMode.swift"
binary_file="$support_dir/vicinae-coffee-mode"
state_dir="$HOME/Library/Application Support/Vicinae"
enabled_file="$state_dir/coffee-mode.enabled"

if [ -f "$enabled_file" ]; then
    rm -f "$enabled_file"
    echo "Coffee mode off"
    exit 0
fi

if ! command -v swiftc >/dev/null 2>&1; then
    echo "Coffee mode needs swiftc; install Xcode Command Line Tools"
    exit 1
fi

mkdir -p "$support_dir" "$state_dir"

if [ ! -x "$binary_file" ] || [ "$source_file" -nt "$binary_file" ]; then
    if ! swiftc -O -framework AppKit -o "$binary_file" "$source_file"; then
        echo "Could not build Coffee Mode"
        exit 1
    fi
fi

touch "$enabled_file"

if ! pgrep -f "$binary_file" >/dev/null 2>&1; then
    nohup "$binary_file" >/dev/null 2>&1 &
fi

echo "Coffee mode on — Mac will stay awake"
