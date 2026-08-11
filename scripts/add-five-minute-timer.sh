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
paused_file="$state_dir/five-minute-timer.paused"

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
remaining_when_paused=0

if [ -f "$paused_file" ]; then
    stored_remaining=$(tr -d '[:space:]' < "$paused_file")
    if [[ "$stored_remaining" =~ ^[0-9]+$ ]]; then
        remaining_when_paused="$stored_remaining"
    fi
elif [ -f "$state_file" ]; then
    stored_end=$(tr -d '[:space:]' < "$state_file")
    if [[ "$stored_end" =~ ^[0-9]+$ ]]; then
        current_end="$stored_end"
    fi
fi

if [ "$remaining_when_paused" -gt 0 ]; then
    new_remaining=$((remaining_when_paused + 300))
    printf '%s\n' "$new_remaining" > "$paused_file"
    remaining=$new_remaining
elif [ "$current_end" -gt "$now" ]; then
    new_end=$((current_end + 300))
    printf '%s\n' "$new_end" > "$state_file"
    remaining=$((new_end - now))
else
    new_end=$((now + 300))
    printf '%s\n' "$new_end" > "$state_file"
    remaining=300
fi

if ! pgrep -f "$binary_file" >/dev/null 2>&1; then
    nohup "$binary_file" >/dev/null 2>&1 &
fi

echo "Timer: $((remaining / 60)) minutes"
