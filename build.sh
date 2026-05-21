#!/bin/bash
echo "=============================================="
echo "Build immagine Docker: lean-ctx-bin-lean-ctx"
echo "=============================================="
echo

docker build -t lean-ctx-bin-lean-ctx "$(dirname "$0")"
if [ $? -ne 0 ]; then
    echo
    echo "[ERRORE] Build fallita. Verifica che Docker sia in esecuzione."
    exit 1
fi

echo
echo "[OK] Immagine lean-ctx-bin-lean-ctx costruita con successo."
echo "Puoi ora eseguire start-mcp.sh per avviare il server MCP."
echo
