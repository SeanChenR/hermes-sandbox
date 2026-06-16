#!/usr/bin/env bash
# Supervisor for an always-on hermes-box:
#   - ensures the container service + hermes-box are running (restarts if they stop)
#   - prevents the Mac from sleeping while it runs (caffeinate)
#
# Meant to be run by the LaunchAgent from install-service.sh (RunAtLoad + KeepAlive).
# LaunchAgents get a minimal PATH, so we set it explicitly and use absolute tools.
set -uo pipefail

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
cd "$(dirname "$0")"

NAME="${HERMES_CONTAINER:-hermes-box}"

# Prevent sleep for as long as this supervisor lives; kill caffeinate on exit so
# the Mac can sleep again once the LaunchAgent is removed/stopped.
/usr/bin/caffeinate -dimsu &
CAFFEINATE_PID=$!
trap 'kill "$CAFFEINATE_PID" 2>/dev/null || true' EXIT INT TERM

while true; do
    # Ensure the container system service is up.
    container system status >/dev/null 2>&1 || container system start >/dev/null 2>&1 || true

    # Ensure hermes-box is running (start.sh creates it if missing, starts if stopped).
    if ! container ls 2>/dev/null | grep -qw "$NAME"; then
        ./start.sh >/dev/null 2>&1 || true
    fi

    sleep 30
done
