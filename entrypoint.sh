#!/bin/sh
set -e

# Render передаёт порт в переменной PORT — используем его как listen port
export N8N_PORT="${PORT:-5678}"
export N8N_LISTEN_ADDRESS="0.0.0.0"

# user folder
mkdir -p "${N8N_USER_FOLDER:-/data}"

# импорт workflows (опционально)
if [ -d /home/node/workflows ] && [ "$(ls -A /home/node/workflows 2>/dev/null)" ]; then
  echo "[entrypoint] Importing workflows from /home/node/workflows..."
  n8n import:workflow --separate --input=/home/node/workflows
  echo "[entrypoint] Workflows imported successfully"
fi

echo "[entrypoint] Starting n8n..."
exec n8n