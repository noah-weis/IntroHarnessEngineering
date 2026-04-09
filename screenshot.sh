#!/bin/bash
# screenshot.sh — Renders index.html and saves a PNG the agent can view.
# Usage: ./screenshot.sh
# Output: screenshot.png in the current directory.

set -euo pipefail

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
HTML_PATH="file://${REPO_DIR}/index.html"
OUT_PATH="${REPO_DIR}/screenshot.png"

"$CHROME" \
  --headless \
  --disable-gpu \
  --hide-scrollbars \
  --window-size=1440,2000 \
  --screenshot="$OUT_PATH" \
  "$HTML_PATH"

echo "Saved screenshot to $OUT_PATH"
