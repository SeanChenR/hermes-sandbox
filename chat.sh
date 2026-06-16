#!/usr/bin/env bash
# Launch the hermes TUI inside the running container.
# Auto-starts the container if it is not up yet.
#
#   ./chat.sh              -> hermes chat
#   ./chat.sh setup        -> hermes setup wizard (model / API keys)
#   ./chat.sh model        -> switch provider/model
set -euo pipefail
cd "$(dirname "$0")"

NAME="${HERMES_CONTAINER:-hermes-box}"
./start.sh >/dev/null
exec container exec -it "${NAME}" hermes "$@"
