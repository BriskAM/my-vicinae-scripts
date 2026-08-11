#!/bin/bash
# @vicinae.schemaVersion 1
# @vicinae.title Region → Fast Vision OCR → Clipboard
# @vicinae.mode silent

set -euo pipefail

# Ensure Swift compiler exists
if ! command -v swiftc >/dev/null 2>&1; then
  echo "Error: swiftc not found. Run: xcode-select --install" >&2
  exit 1
fi

# Cache paths
CACHE_DIR="$HOME/Library/Application Support/rs_vision_ocr"
SRC="$CACHE_DIR/rs_vision_ocr.swift"
BIN="$CACHE_DIR/rs_vision_ocr"
mkdir -p "$CACHE_DIR"

# Swift source if missing
if [ ! -f "$SRC" ]; then
cat > "$SRC" <<'SWIFT'
import Foundation
import Vision
import AppKit

guard CommandLine.arguments.count > 1 else { exit(2) }
let path = CommandLine.arguments[1]
let url = URL(fileURLWithPath: path)
guard let image = NSImage(contentsOf: url),
      let tiff = image.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let cg = rep.cgImage else { exit(3) }

let request = VNRecognizeTextRequest()
request.recognitionLevel = .fast
request.usesLanguageCorrection = false

let handler = VNImageRequestHandler(cgImage: cg, options: [:])

do {
    try handler.perform([request])
    guard let results = request.results as? [VNRecognizedTextObservation] else { exit(0) }
    let lines = results.compactMap { $0.topCandidates(1).first?.string }
    if lines.isEmpty { exit(0) }
    print(lines.joined(separator: "\n"))
} catch {
    exit(4)
}
SWIFT
fi

# Compile only if missing or outdated
if [ ! -x "$BIN" ] || [ "$SRC" -nt "$BIN" ]; then
  if ! swiftc -O -framework Vision -framework AppKit -o "$BIN" "$SRC"; then
    echo "OCR setup failed: could not build the helper"
    exit 1
  fi
fi

# Generate unique image path
IMG="/tmp/rs_ocr_img_$(date +%s%N).png"
trap 'rm -f "$IMG"' EXIT

# Capture screenshot to that file (ignore overwrite)
if ! screencapture -i -x "$IMG"; then
  echo "OCR cancelled"
  exit 0
fi

# Run OCR and copy to clipboard
if ! OCR_TEXT=$("$BIN" "$IMG"); then
  echo "OCR failed"
  exit 1
fi

if [ -z "$OCR_TEXT" ]; then
  echo "No text found"
  exit 0
fi

printf '%s\n' "$OCR_TEXT" | pbcopy
echo "OCR copied to clipboard"
