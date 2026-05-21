@echo off
echo ==============================================
echo Configurazione ambiente lean-ctx per Windows
echo ==============================================
echo.

:: Verifica che WSL sia installato
wsl -- echo "" <nul >nul 2>&1
if errorlevel 1 (
    echo [AVVISO] WSL non sembra installato o non e avviabile.
    echo Il progetto richiede WSL2 con Docker installato al suo interno.
    echo Installalo da: https://docs.microsoft.com/it-it/windows/wsl/install
    echo.
)

:: 1. Crea la cartella pubblica se non esiste
if not exist "C:\Users\Public\lean-ctx" (
    echo Creazione cartella C:\Users\Public\lean-ctx...
    mkdir "C:\Users\Public\lean-ctx"
)

:: 2. Copia lo script start-mcp.bat
echo Copia di start-mcp.bat in C:\Users\Public\lean-ctx\...
copy /y "%~dp0start-mcp.bat" "C:\Users\Public\lean-ctx\start-mcp.bat"

:: 3. Crea il file .env di default se non esiste
if exist "C:\Users\Public\lean-ctx\.env" goto env_exists

echo Creazione file .env di default...
(
    echo PROJECTS_DIR=%USERPROFILE%\Desktop\progetti
    echo WSL_DISTRO=Ubuntu
)> "C:\Users\Public\lean-ctx\.env"
echo [OK] File .env generato in C:\Users\Public\lean-ctx\.env
echo Percorso di default: %USERPROFILE%\Desktop\progetti
echo Distro WSL di default: Ubuntu
echo (Modifica il file .env se la tua configurazione e diversa).
goto end

:env_exists
echo [INFO] Il file .env esiste gia in C:\Users\Public\lean-ctx\.env, salto la creazione per non sovrascrivere le tue modifiche.

:end
echo.
echo ==============================================
echo Setup completato con successo!
echo Ricorda di:
echo   1. Eseguire build.bat per costruire l'immagine Docker
echo   2. Configurare mcp_config.json come descritto in readme.md
echo ==============================================
echo.
pause
