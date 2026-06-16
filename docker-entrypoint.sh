#!/usr/bin/env bash
# Seed the data dir on first run when the bind-mounted ./hermes-data is empty,
# then hand off to the requested command (defaults to `hermes`).
set -e

if [ -z "$(ls -A /root/.hermes 2>/dev/null)" ]; then
    echo "[entrypoint] /root/.hermes is empty — seeding from baked defaults..."
    cp -a /opt/hermes-seed/. /root/.hermes/ 2>/dev/null || true
fi

exec "$@"
