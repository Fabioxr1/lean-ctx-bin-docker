#!/bin/bash
echo "=============================================="
echo "Configurazione ambiente lean-ctx per Linux"
echo "=============================================="
echo

# 1. Crea la cartella ~/.config/lean-ctx se non esiste
mkdir -p "$HOME/.config/lean-ctx"

# 2. Copia lo script di avvio e rendilo eseguibile
echo "Copia di start-mcp.sh in ~/.config/lean-ctx/..."
cp "$(dirname "$0")/start-mcp.sh" "$HOME/.config/lean-ctx/start-mcp.sh"
chmod +x "$HOME/.config/lean-ctx/start-mcp.sh"

# 3. Crea il file .env di default se non esiste
if [ ! -f "$HOME/.config/lean-ctx/.env" ]; then
    echo "PROJECTS_DIR=$HOME/progetti" > "$HOME/.config/lean-ctx/.env"
    echo
    echo "[OK] File .env generato in ~/.config/lean-ctx/.env"
    echo "Percorso di default impostato a: $HOME/progetti"
    echo "(Se i tuoi progetti si trovano altrove, modifica questo file)."
else
    echo
    echo "[INFO] Il file .env esiste gia in ~/.config/lean-ctx/.env, salto la creazione."
fi

echo
echo "=============================================="
echo "Setup completato con successo!"
echo "Ricorda di configurare mcp_config.json come descritto in readme.md."
echo "=============================================="
echo
