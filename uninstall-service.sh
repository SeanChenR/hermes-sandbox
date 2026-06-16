#!/usr/bin/env bash
# Remove the always-on LaunchAgent so the Mac can sleep normally again.
# Does NOT stop hermes-box itself — use ./stop.sh for that.
set -uo pipefail
cd "$(dirname "$0")"

LABEL="com.hermes-sandbox.keepalive"
PLIST="$HOME/Library/LaunchAgents/${LABEL}.plist"

launchctl bootout "gui/$(id -u)/${LABEL}" 2>/dev/null \
    || launchctl unload -w "$PLIST" 2>/dev/null || true
rm -f "$PLIST"

# Backstop: kill any caffeinate left over from the supervisor.
pkill -f "caffeinate -dimsu" 2>/dev/null || true

echo "Removed ${LABEL}. The Mac can sleep normally now."
echo "hermes-box is untouched; use ./stop.sh to stop it."
