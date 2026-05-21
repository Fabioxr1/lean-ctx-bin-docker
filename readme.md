# Impostazioni MCP (lean-ctx-docker)

Questo progetto implementa un server MCP containerizzato basato sulla libreria ufficiale **[lean-ctx](https://github.com/yvgude/lean-ctx)** (distribuita come pacchetto npm **`lean-ctx-bin`**).
`lean-ctx` funge da livello di ingegneria del contesto cognitivo per gli agenti AI, ottimizzando le letture dei file, memorizzando in cache il contesto non modificato e comprimendo le risposte per ridurre drasticamente (fino al 99%) il consumo dei token.

Questo documento raccoglie la configurazione dell'MCP sia per Windows che per Linux. 
Tutti i file descritti di seguito sono inclusi in questa cartella (`lean-ctx-bin`) per garantire la portabilità del repository.

---

## 🚀 Primo Avvio (Setup Automatico)

Per configurare l'ambiente locale al primo avvio su una nuova macchina, segui questi due passi:

### Passo 1 — Setup
*   **Su Windows**: Esegui `setup.bat` (doppio clic o da terminale). Crea la cartella di configurazione e il file `.env`.
*   **Su Linux**: Esegui `setup.sh` da terminale (`./setup.sh`). Crea `~/.config/lean-ctx` e il file `.env`.

### Passo 2 — Build immagine Docker
*   **Su Windows**: Esegui `build.bat`. Costruisce l'immagine Docker `lean-ctx-bin-lean-ctx`.
*   **Su Linux**: Esegui `build.sh`. Costruisce l'immagine Docker `lean-ctx-bin-lean-ctx`.

---

## 💻 Configurazione Windows (Dettagli)

### 1. File delle variabili d'ambiente
Percorso file: `C:\Users\Public\lean-ctx\.env`
Contenuto:
```env
PROJECTS_DIR=C:\Users\tuo_utente\Desktop\progetti
WSL_DISTRO=Ubuntu
```
*(Modifica `PROJECTS_DIR` con il percorso reale dei tuoi progetti e `WSL_DISTRO` con il nome esatto della tua distribuzione WSL, se diverso da `Ubuntu`).*

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
Aggiungere a `mcpServers` all'interno del file di configurazione dell'IDE.
Sostituisci `/home/tuo_utente` con il tuo percorso home reale (usa `echo $HOME` nel terminale per ottenerlo):
```json
    "lean-ctx-docker": {
      "command": "/bin/bash",
      "args": [
        "/home/tuo_utente/.config/lean-ctx/start-mcp.sh"
      ]
    }
```

---

## 🛡️ Intelligent Loop Guard & Token Estimator

Questo server MCP include un proxy intermedio (`loop-guard.js`) che fornisce due funzionalità chiave di controllo e telemetria:

### 1. Loop Guard (Protezione Ricorsione)
Rileva se l'agente AI entra in un loop autonomo infinito. Se lo stesso tool MCP viene invocato con gli stessi identici argomenti per **5 volte consecutive** all'interno di una finestra temporale di **5 secondi**, il proxy blocca la chiamata e restituisce all'IDE una risposta di errore JSON-RPC. Questo previene lo spreco involontario di token e arresta il loop.

### 2. Token Savings Estimator (Stima Risparmio Token)
Il proxy monitora le transazioni in tempo reale ed effettua una stima dei token risparmiati:
- **Input**: Confronta la dimensione reale dei file letti sul disco con i dati compressi inviati all'IDE da `lean-ctx` (per esempio, le letture in cache).
- **Output**: Calcola il risparmio derivante dall'utilizzo del **Token Dense Dialect (TDD)** compressore.

Le metriche aggregate sono salvate in formato JSON in `~/.config/lean-ctx/stats.json` e stampate in tempo reale nel log `stderr` dell'MCP nell'IDE.


bash:
cat ~/.config/lean-ctx/stats.json


