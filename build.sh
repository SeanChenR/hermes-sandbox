#!/usr/bin/env bash
# Build the Hermes Agent image with Apple `container`.
set -euo pipefail
cd "$(dirname "$0")"

IMAGE="${HERMES_IMAGE:-hermes:dev}"

echo "Building ${IMAGE} ..."
container build --file Containerfile --tag "${IMAGE}" .
echo "Done. Run it with ./run.sh"
