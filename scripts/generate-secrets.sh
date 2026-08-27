#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if [ -f .env ]; then
    echo "[INFO] .env file already exists. Preserving existing secrets."
    exit 0
fi

DB_PASS=$(openssl rand -hex 16 2>/dev/null || echo "tm3l_time_machine_password")
JWT_SECRET=$(openssl rand -hex 32 2>/dev/null || date +%s | shasum -a 256 | head -c 64)

cat <<ENVEOF > .env
PORT=8084
DATABASE_URL=postgres://tm3l_protocol:${DB_PASS}@protocol-db:5432/tm3l_protocol?sslmode=disable
POSTGRES_USER=tm3l_protocol
POSTGRES_PASSWORD=${DB_PASS}
POSTGRES_DB=tm3l_protocol
TM3L_JWT_SECRET=${JWT_SECRET}
ENVEOF

echo "[OK] Generated .env for Protocol Time Machine."
