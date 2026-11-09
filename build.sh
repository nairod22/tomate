#!/bin/bash
# Build Tomate.app (release). Usage: ./build.sh [--install]
set -euo pipefail
cd "$(dirname "$0")"

swift build -c release
BIN_DIR="$(swift build -c release --show-bin-path)"

APP="build/Tomate.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN_DIR/Tomate" "$APP/Contents/MacOS/Tomate"
cp Resources/Info.plist "$APP/Contents/Info.plist"
codesign --force --sign - "$APP"

if [[ "${1:-}" == "--install" ]]; then
  pkill -x Tomate 2>/dev/null || true
  rm -rf /Applications/Tomate.app
  cp -R "$APP" /Applications/Tomate.app
  echo "Installed /Applications/Tomate.app"
else
  echo "Built $APP"
fi
