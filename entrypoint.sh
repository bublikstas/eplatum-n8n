#!/bin/sh
set -eu

MARKER="/data/.n8n/.workflows_imported"
IMPORT_DIR="/home/node/workflows"

# Опционально: форс-импорт через переменную окружения FORCE_IMPORT=1
if [ "${FORCE_IMPORT:-}" = "1" ]; then
  rm -f "$MARKER"
fi

if [ -d "$IMPORT_DIR" ] && [ "$(ls -A "$IMPORT_DIR" 2>/dev/null)" ]; then
  if [ -f "$MARKER" ]; then
    echo "[entrypoint] Workflows already imported; skipping"
  else
    echo "[entrypoint] Importing workflows from $IMPORT_DIR..."
    n8n import:workflow --separate --input="$IMPORT_DIR"
    touch "$MARKER"
    echo "[entrypoint] Workflows imported."
  fi
fi

exec n8n