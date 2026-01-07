#!/usr/bin/env bash
set -euo pipefail

echo "[import] sanitizing workflows..."
python3 ./scripts/sanitize_workflow_ids.py

echo "[import] importing into n8n..."
npx n8n import:workflow --separate --input=./workflows_sanitized

echo "[import] done."