# Impostazioni MCP (lean-ctx-docker)

Questo documento raccoglie la configurazione dell'MCP sia per Windows che per Linux. 
Tutti i file descritti di seguito sono inclusi in questa cartella (`lean-ctx-bin`) per garantire la portabilità del repository.

---

## 🚀 Primo Avvio (Setup Automatico)

Per configurare l'ambiente locale al primo avvio su una nuova macchina:

*   **Su Windows**: Esegui lo script `setup.bat` (doppio clic o da terminale). Lo script copierà i file necessari in `C:\Users\Public\lean-ctx` e creerà un file `.env` di default.
*   **Su Linux**: Esegui lo script `setup.sh` da terminale (`./setup.sh`). Lo script copierà i file in `~/.config/lean-ctx` e creerà un file `.env` di default.

---

## 💻 Configurazione Windows (Dettagli)

### 1. File delle variabili d'ambiente
Percorso file: `C:\Users\Public\lean-ctx\.env`
Contenuto:
```env
PROJECTS_DIR=C:\Users\Feedweb F\Desktop\progetti
```
*(Modifica questo percorso se la cartella dei tuoi progetti si trova altrove su questa macchina).*

### 2. Configurazione `mcp_config.json`
Aggiungere a `mcpServers` all'interno del file di configurazione dell'IDE:
```json
    "lean-ctx-docker": {
      "command": "cmd.exe",
      "args": [
        "/c",
        "C:\\Users\\Public\\lean-ctx\\start-mcp.bat"
      ]
    }
```

---

## 🐧 Configurazione Linux (Dettagli)

### 1. File delle variabili d'ambiente
Percorso file: `~/.config/lean-ctx/.env`
Contenuto:
```env
PROJECTS_DIR=/home/tuo_utente/progetti
```

### 2. Configurazione `mcp_config.json`
Aggiungere a `mcpServers` all'interno del file di configurazione dell'IDE (sostituendo `tuo_utente` con il tuo username reale su Linux):
```json
    "lean-ctx-docker": {
      "command": "/bin/bash",
      "args": [
        "/home/tuo_utente/.config/lean-ctx/start-mcp.sh"
      ]
    }
```
