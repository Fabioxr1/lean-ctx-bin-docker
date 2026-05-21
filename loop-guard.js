const readline = require('readline');
const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

// Configurazione
const STATS_FILE = '/root/.config/lean-ctx/stats.json';
const MAX_CONSECUTIVE_IDENTICAL = 5;
const LOOP_TIME_WINDOW_MS = 5000; // 5 secondi
const TOKEN_CHAR_RATIO = 4; // Rapporto approssimativo caratteri/token

// Stato
let callHistory = [];
const pendingRequests = new Map();

// Statistiche cumulative
let totalSavedInputTokens = 0;
let totalSavedOutputTokens = 0;

// Inizializza statistiche
function ensureStatsDir() {
  const dir = path.dirname(STATS_FILE);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

function loadStats() {
  try {
    ensureStatsDir();
    if (fs.existsSync(STATS_FILE)) {
      const data = JSON.parse(fs.readFileSync(STATS_FILE, 'utf8'));
      totalSavedInputTokens = data.totalSavedInputTokens || 0;
      totalSavedOutputTokens = data.totalSavedOutputTokens || 0;
    }
  } catch (err) {
    // Silente in caso di primo avvio
  }
}

function saveStats() {
  try {
    ensureStatsDir();
    fs.writeFileSync(STATS_FILE, JSON.stringify({
      totalSavedInputTokens,
      totalSavedOutputTokens,
      updatedAt: new Date().toISOString()
    }, null, 2));
  } catch (err) {
    console.error(`[LoopGuard] Errore nel salvataggio delle statistiche: ${err.message}`);
  }
}

loadStats();

// Avvia il server lean-ctx originale come processo figlio
const child = spawn('lean-ctx', [], {
  stdio: ['pipe', 'pipe', 'pipe']
});

// Interfaccia per leggere stdin dell'IDE riga per riga
const ideReader = readline.createInterface({
  input: process.stdin,
  output: null,
  terminal: false
});

// Interfaccia per leggere stdout del server lean-ctx riga per riga
const mcpReader = readline.createInterface({
  input: child.stdout,
  output: null,
  terminal: false
});

// Inoltra stderr di lean-ctx a stderr del processo principale per preservare i log originali
child.stderr.on('data', (data) => {
  process.stderr.write(data);
});

// Gestione dell'uscita del processo figlio
child.on('close', (code) => {
  saveStats();
  process.exit(code);
});

// 1. Gestione Richieste (IDE -> LoopGuard -> lean-ctx)
ideReader.on('line', (line) => {
  if (!line.trim()) return;

  try {
    const request = JSON.parse(line);

    // Gestiamo solo le chiamate ai tool
    if (request.method === 'tools/call' && request.params && request.params.name) {
      const toolName = request.params.name;
      const toolArgs = request.params.arguments || {};
      const argsStr = JSON.stringify(toolArgs);
      const now = Date.now();

      // Pulisce la cronologia oltre la finestra temporale
      callHistory = callHistory.filter(c => now - c.timestamp < LOOP_TIME_WINDOW_MS);

      // Controlla se ci sono chiamate consecutive identiche
      const identicalCalls = callHistory.filter(c => c.toolName === toolName && c.argsStr === argsStr);

      if (identicalCalls.length >= MAX_CONSECUTIVE_IDENTICAL) {
        // RILEVATO LOOP: Blocca la richiesta inviando un errore standard JSON-RPC
        const errorResponse = {
          jsonrpc: "2.0",
          id: request.id,
          error: {
            code: -32000,
            message: `[LoopGuard] Rilevato loop ricorsivo su '${toolName}'. Chiamata bloccata per prevenire consumi di token inutili.`
          }
        };
        process.stdout.write(JSON.stringify(errorResponse) + '\n');

        // Log visibile nel pannello dei log MCP dell'IDE
        console.error(`\n⚠️ [LoopGuard] BLOCCATO LOOP RICORSIVO per il tool '${toolName}' con argomenti: ${argsStr}\n`);
        return;
      }

      // Registra la chiamata corrente
      callHistory.push({ toolName, argsStr, timestamp: now });
      pendingRequests.set(request.id, {
        toolName,
        toolArgs,
        requestSize: line.length,
        timestamp: now
      });
    }
  } catch (err) {
    // Se non è JSON valido, lascia scorrere (es. messaggi di inizializzazione)
  }

  // Inoltra la riga a lean-ctx
  child.stdin.write(line + '\n');
});

// 2. Gestione Risposte (lean-ctx -> LoopGuard -> IDE)
mcpReader.on('line', (line) => {
  if (!line.trim()) return;

  try {
    const response = JSON.parse(line);

    // Controlliamo se è una risposta ad una richiesta pendente
    if (response.id !== undefined && pendingRequests.has(response.id)) {
      const req = pendingRequests.get(response.id);
      pendingRequests.delete(response.id);

      const responseSize = line.length;
      const responseTokens = Math.ceil(responseSize / TOKEN_CHAR_RATIO);
      let savedInput = 0;
      let savedOutput = 0;

      // Stima risparmio per ctx_read (confronto con file reale)
      if (req.toolName === 'ctx_read' && req.toolArgs && req.toolArgs.path) {
        const filePath = req.toolArgs.path;
        try {
          if (fs.existsSync(filePath)) {
            const stats = fs.statSync(filePath);
            const rawFileTokens = Math.ceil(stats.size / TOKEN_CHAR_RATIO);
            // Il risparmio è la differenza tra leggere tutto il file e la risposta compressa fornita da lean-ctx
            savedInput = Math.max(0, rawFileTokens - responseTokens);
          }
        } catch (e) {
          // Ignorato in caso di problemi di accesso al file
        }
      }

      // Stima risparmio per Token Dense Dialect (TDD) sulle risposte compresse
      // Il TDD solitamente riduce l'output del 60-70% (rapporto stimato di 2.5x rispetto al testo completo)
      if (response.result && response.result.content) {
        savedOutput = Math.ceil(responseTokens * 1.5);
      }

      // Aggiorna le statistiche globali
      if (savedInput > 0 || savedOutput > 0) {
        totalSavedInputTokens += savedInput;
        totalSavedOutputTokens += savedOutput;
        saveStats();

        // Stampa il report in rosso/verde su stderr per renderlo visibile nei log MCP dell'IDE
        console.error(
          `[LoopGuard] 📊 Tool: ${req.toolName} | ` +
          `Risparmio stimato: Ingr. ${savedInput.toLocaleString()} tok, Usc. ${savedOutput.toLocaleString()} tok | ` +
          `Totali risparmiati: Ingr. ${totalSavedInputTokens.toLocaleString()} tok, Usc. ${totalSavedOutputTokens.toLocaleString()} tok`
        );
      }
    }
  } catch (err) {
    // Non è JSON, inoltra normalmente
  }

  // Inoltra la riga all'IDE
  process.stdout.write(line + '\n');
});

// Gestione errori di input/output
process.on('SIGINT', () => {
  child.kill('SIGINT');
  saveStats();
  process.exit(0);
});

process.on('SIGTERM', () => {
  child.kill('SIGTERM');
  saveStats();
  process.exit(0);
});
