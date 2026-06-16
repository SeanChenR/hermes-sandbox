#!/usr/bin/env bash
# Install a LaunchAgent that keeps hermes-box always-on:
#   - auto-starts it at login, restarts it if it dies, survives reboot
#   - keeps the Mac awake while it runs
# Reversible: ./uninstall-service.sh
set -euo pipefail
cd "$(dirname "$0")"

LABEL="com.hermes-sandbox.keepalive"
PLIST="$HOME/Library/LaunchAgents/${LABEL}.plist"
SCRIPT="$(pwd)/keepalive.sh"
LOG="$(pwd)/keepalive.log"

mkdir -p "$HOME/Library/LaunchAgents"

cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${LABEL}</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>${SCRIPT}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>${LOG}</string>
    <key>StandardErrorPath</key>
    <string>${LOG}</string>
</dict>
</plist>
EOF
echo "Wrote ${PLIST}"

# (Re)load it. bootout first in case it is already loaded; fall back to legacy load.
launchctl bootout "gui/$(id -u)/${LABEL}" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST" 2>/dev/null || launchctl load -w "$PLIST"

echo "Loaded ${LABEL}."
echo "hermes-box will now auto-start (incl. after reboot) and the Mac stays awake while it runs."
echo "Log: ${LOG}   |   Remove with: ./uninstall-service.sh"
