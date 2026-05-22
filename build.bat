@echo off
echo ==============================================
echo Build immagine Docker: lean-ctx-bin-lean-ctx
echo ==============================================
echo.

docker build -t lean-ctx-bin-lean-ctx "%~dp0."
if errorlevel 1 (
    echo.
    echo [ERRORE] Build fallita. Verifica che Docker sia in esecuzione.
    exit /b 1
)

echo.
echo [OK] Immagine lean-ctx-bin-lean-ctx costruita con successo.
echo Puoi ora eseguire start-mcp.bat per avviare il server MCP.
echo.
pause
