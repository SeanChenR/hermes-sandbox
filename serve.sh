#!/usr/bin/env bash
# Serve the agent-generated Medium HTML reports on localhost (for this Mac).
# Reports land in ./hermes-data/reports (bind-mounted from the container).
#   ./serve.sh [port]   (default 8000)   — Ctrl-C to stop
set -euo pipefail
cd "$(dirname "$0")/hermes-data/reports"

PORT="${1:-8000}"
python3 -m http.server "$PORT" >/dev/null 2>&1 &
SRV=$!
trap 'kill "$SRV" 2>/dev/null' EXIT
sleep 1
open "http://localhost:${PORT}/" 2>/dev/null || true
echo "Serving ./hermes-data/reports at http://localhost:${PORT}/  (Ctrl-C to stop)"
wait "$SRV"
