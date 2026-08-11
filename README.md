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

The scripts use Vicinae's `silent` output mode for HUD feedback.

The timer script compiles a small native AppKit status-bar helper on first use. Assign
the **Add 5 Minutes to Timer** command to a Vicinae shortcut such as Hyper+T. Each
invocation adds five minutes to the existing timer.
