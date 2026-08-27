#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
echo "==> Stopping TM3L Protocol Time Machine stack..."
docker compose down
