#!/usr/bin/env bash
# Start the long-running Hermes container (idempotent).
#
# Runs `sleep infinity` as the main process so the container stays alive; the
# entrypoint seeds /root/.hermes from baked defaults on first start if the
# bind-mounted ./hermes-data is empty. Anything you install inside (apt, etc.)
# persists for the lifetime of this container.
set -euo pipefail
cd "$(dirname "$0")"

IMAGE="${HERMES_IMAGE:-hermes:dev}"
NAME="${HERMES_CONTAINER:-hermes-box}"
DATA_DIR="$(pwd)/hermes-data"
mkdir -p "${DATA_DIR}"

if container inspect "${NAME}" >/dev/null 2>&1; then
    # Exists (running or stopped) — make sure it is started.
    container start "${NAME}" >/dev/null 2>&1 || true
    echo "Container '${NAME}' is up."
else
    container run -d --name "${NAME}" \
        --volume "${DATA_DIR}:/root/.hermes" \
        "${IMAGE}" sleep infinity
    echo "Container '${NAME}' created and started."
fi

echo "  ./shell.sh   -> ubuntu shell inside the container"
echo "  ./chat.sh    -> hermes TUI"
echo "  ./stop.sh    -> stop it (add --rm to delete; ./hermes-data is kept)"
