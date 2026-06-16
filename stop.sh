#!/usr/bin/env bash
# Stop the Hermes container. Pass --rm to also delete it.
# Your state in ./hermes-data is always kept either way.
set -euo pipefail
cd "$(dirname "$0")"

NAME="${HERMES_CONTAINER:-hermes-box}"

echo "Stopping '${NAME}'..."
container stop "${NAME}" 2>/dev/null || true

if [ "${1:-}" = "--rm" ]; then
    container delete "${NAME}" 2>/dev/null || true
    echo "Removed '${NAME}'. Anything installed inside is gone; ./hermes-data is kept."
else
    echo "Stopped. ./shell.sh or ./chat.sh will restart it (installed packages preserved)."
fi
