#!/usr/bin/env sh
set -eu

export N8N_PORT="${PORT:-5678}"

echo "[render] sanitizing workflows..."
python3 ./scripts/sanitize_workflow_ids.py || true

echo "[render] importing workflows..."
npx n8n import:workflow --separate --input=./workflows_sanitized || true

echo "[render] starting n8n..."
exec npx n8n start
