#!/bin/bash
# default se .env non esiste
PROJECTS_DIR="$HOME/progetti"

# Carica .env se esiste
# Uso while+read invece di export $(xargs) per gestire path con spazi
ENV_FILE="$HOME/.config/lean-ctx/.env"
if [ -f "$ENV_FILE" ]; then
    while IFS='=' read -r key value; do
        # Salta commenti e righe vuote
        [[ "$key" =~ ^#.*$ ]] && continue
        [[ -z "$key" ]] && continue
        export "$key=$value"
    done < "$ENV_FILE"
fi

# Avvia Docker nativamente
docker run -i --rm \
  -v "${PROJECTS_DIR}:${PROJECTS_DIR}" \
  -v "lean_ctx_data:/root/.config/lean-ctx" \
  -e "LEAN_CTX_DATA_DIR=/root/.config/lean-ctx" \
  -w "${PROJECTS_DIR}" \
  lean-ctx-bin-lean-ctx lean-ctx
