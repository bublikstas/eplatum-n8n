#!/usr/bin/env bash
set -euo pipefail

# Ensure N8N_USER_FOLDER exists
if [ -n "${N8N_USER_FOLDER:-}" ]; then
    mkdir -p "$N8N_USER_FOLDER"
    echo "[entrypoint] Created/verified N8N_USER_FOLDER: $N8N_USER_FOLDER"
fi

# Find n8n binary
N8N_BIN=$(command -v n8n || echo "/usr/local/bin/n8n")
if [ ! -f "$N8N_BIN" ]; then
    echo "[entrypoint] Warning: n8n binary not found at $N8N_BIN, trying default path"
    N8N_BIN="n8n"
fi

# Import workflows if available
WORKFLOWS_DIR=""
if [ -d "/home/node/workflows_prod" ] && [ "$(ls -A /home/node/workflows_prod 2>/dev/null)" ]; then
    WORKFLOWS_DIR="/home/node/workflows_prod"
elif [ -d "/home/node/workflows" ] && [ "$(ls -A /home/node/workflows 2>/dev/null)" ]; then
    WORKFLOWS_DIR="/home/node/workflows"
fi

if [ -n "$WORKFLOWS_DIR" ]; then
    echo "[entrypoint] Importing workflows from $WORKFLOWS_DIR..."
    if "$N8N_BIN" import:workflow --separate --input="$WORKFLOWS_DIR" 2>/dev/null || true; then
        echo "[entrypoint] Workflows imported successfully"
    else
        echo "[entrypoint] Workflow import skipped (no valid workflows or already imported)"
    fi
else
    echo "[entrypoint] No workflows directory found, skipping import"
fi

# Start n8n
echo "[entrypoint] Starting n8n..."
exec "$N8N_BIN" "$@"
