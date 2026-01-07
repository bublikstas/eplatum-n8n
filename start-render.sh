#!/usr/bin/env bash
set -euo pipefail
export N8N_PORT="${PORT:-5678}"
bash ./scripts/import_workflows.sh || true
exec npx n8n start
