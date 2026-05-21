#!/bin/bash
# default se .env non esiste
PROJECTS_DIR="$HOME/progetti"

# Carica .env se esiste
ENV_FILE="$HOME/.config/lean-ctx/.env"
if [ -f "$ENV_FILE" ]; then
    export $(grep -v '^#' "$ENV_FILE" | xargs)
fi

# Avvia Docker nativamente
docker run -i --rm \
  -v "${PROJECTS_DIR}:${PROJECTS_DIR}" \
  -v "lean_ctx_data:/root/.config/lean-ctx" \
  -e "LEAN_CTX_DATA_DIR=/root/.config/lean-ctx" \
  -w "${PROJECTS_DIR}" \
  lean-ctx-bin-lean-ctx lean-ctx
