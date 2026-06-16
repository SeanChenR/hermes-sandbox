#!/usr/bin/env bash
# Drop into an interactive ubuntu shell inside the running Hermes container.
# Auto-starts the container if it is not up yet.
set -euo pipefail
cd "$(dirname "$0")"

NAME="${HERMES_CONTAINER:-hermes-box}"
./start.sh >/dev/null
exec container exec -it "${NAME}" bash
