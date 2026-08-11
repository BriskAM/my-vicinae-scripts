#!/bin/bash

# @vicinae.schemaVersion 1
# @vicinae.title Add 5 Minutes to Timer
# @vicinae.mode silent
# @vicinae.keywords ["timer", "pomodoro", "focus"]

set -euo pipefail

support_dir="$HOME/.local/share/vicinae/support"
source_file="$support_dir/VicinaeFiveMinuteTimer.swift"
binary_file="$support_dir/vicinae-five-minute-timer"
state_dir="$HOME/Library/Application Support/Vicinae"
state_file="$state_dir/five-minute-timer.end"

if ! command -v swiftc >/dev/null 2>&1; then
    echo "Timer setup needs swiftc; install Xcode Command Line Tools"
    exit 1
fi

mkdir -p "$state_dir"

if [ ! -x "$binary_file" ] || [ "$source_file" -nt "$binary_file" ]; then
    if ! swiftc -O -framework AppKit -o "$binary_file" "$source_file"; then
        echo "Could not build the menu-bar timer"
        exit 1
    fi
fi

now=$(date +%s)
current_end=0
if [ -f "$state_file" ]; then
    stored_end=$(tr -d '[:space:]' < "$state_file")
    if [[ "$stored_end" =~ ^[0-9]+$ ]]; then
        current_end="$stored_end"
    fi
fi

if [ "$current_end" -gt "$now" ]; then
    new_end=$((current_end + 300))
else
    new_end=$((now + 300))
fi

temporary_state="$state_file.$$"
printf '%s\n' "$new_end" > "$temporary_state"
mv "$temporary_state" "$state_file"

if ! pgrep -f "$binary_file" >/dev/null 2>&1; then
    nohup "$binary_file" >/dev/null 2>&1 &
fi

remaining=$((new_end - now))
echo "Timer: $((remaining / 60)) minutes"
