@echo off
echo ==============================================
echo Configurazione ambiente lean-ctx per Windows
echo ==============================================
echo.

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
echo PROJECTS_DIR=%USERPROFILE%\Desktop\progetti> "C:\Users\Public\lean-ctx\.env"
echo [OK] File .env generato in C:\Users\Public\lean-ctx\.env
echo Percorso di default impostato a: %USERPROFILE%\Desktop\progetti
echo (Se i tuoi progetti si trovano altrove, modifica questo file).
goto end

:env_exists
echo [INFO] Il file .env esiste gia in C:\Users\Public\lean-ctx\.env, salto la creazione per non sovrascrivere le tue modifiche.

:end
echo.
echo ==============================================
echo Setup completato con successo!
echo Ricorda di configurare mcp_config.json come descritto in readme.md.
echo ==============================================
echo.
pause
