#!/usr/bin/env bash
set -euo pipefail

echo "=== Checking TM3L Protocol Time Machine Service Health ==="

SERVER_HTTP=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8084/api/health || echo "000")
if [ "$SERVER_HTTP" != "000" ]; then
    echo "[OK] Protocol Time Machine Server is responding on http://localhost:8084 (HTTP $SERVER_HTTP)."
else
    echo "[WARN] Protocol Time Machine Server is not responding on port 8084."
fi

EXPLORER_HTTP=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5176/ || echo "000")
if [ "$EXPLORER_HTTP" = "200" ]; then
    echo "[OK] D3 Visualization Explorer is responding on http://localhost:5176."
else
    echo "[WARN] D3 Visualization Explorer returned HTTP $EXPLORER_HTTP on port 5176."
fi

echo "=== Health check finished ==="
