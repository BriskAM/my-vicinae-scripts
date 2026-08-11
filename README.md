# My Vicinae Scripts

Personal Vicinae script commands for macOS.

## Installation

Copy the scripts into Vicinae's script directory:

```bash
mkdir -p ~/.local/share/vicinae/scripts
cp scripts/*.sh ~/.local/share/vicinae/scripts/
```

Then run **Reload Script Directories** from Vicinae's root search.

## Included scripts

- Copy selected Finder items to the clipboard as paths
- Open selected Finder items in Zed
- Copy a selected screen region
- OCR a selected screen region to the clipboard
- Open Downloads, the home folder, or recent downloads
- Search selected text on Google or open a selected link
- Add five minutes to a persistent menu-bar timer
- Toggle Coffee Mode to keep the Mac awake

The scripts use Vicinae's `silent` output mode for HUD feedback.

The timer script compiles a small native AppKit status-bar helper on first use. Assign
the **Add 5 Minutes to Timer** command to a Vicinae shortcut such as Hyper+T. Each
invocation adds five minutes to the existing timer.

Click the running timer in the menu bar for controls to subtract one minute, add five
minutes, pause/resume, reset, or quit the timer. While the timer is actively counting,
it also runs macOS `caffeinate`; pausing, resetting, finishing, or quitting stops it.

Assign **Toggle Coffee Mode** to a shortcut such as Hyper+C. When enabled, a native
Apple SF Symbol (`cup.and.saucer.fill`) appears in the menu bar and `caffeinate` keeps
the Mac awake. Click the icon to turn Coffee Mode off; there is intentionally only one
off action because quitting and turning it off have the same effect.
