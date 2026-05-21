@echo off
setlocal enabledelayedexpansion

:: Defaults
set "PROJECTS_DIR=%USERPROFILE%\Desktop\progetti"
set "WSL_DISTRO=Ubuntu"

:: Load variables from .env if it exists
if exist "C:\Users\Public\lean-ctx\.env" (
    for /f "usebackq delims== tokens=1,*" %%a in ("C:\Users\Public\lean-ctx\.env") do (
        set "KEY=%%a"
        set "VAL=%%b"
        if "!KEY!"=="PROJECTS_DIR" set "PROJECTS_DIR=!VAL!"
        if "!KEY!"=="WSL_DISTRO"   set "WSL_DISTRO=!VAL!"
    )
)

:: Trim trailing spaces from PROJECTS_DIR
:trim_projects
if "!PROJECTS_DIR:~-1!"==" " (
    set "PROJECTS_DIR=!PROJECTS_DIR:~0,-1!"
    goto trim_projects
)

:: Trim trailing spaces from WSL_DISTRO
:trim_distro
if "!WSL_DISTRO:~-1!"==" " (
    set "WSL_DISTRO=!WSL_DISTRO:~0,-1!"
    goto trim_distro
)

:: Verifica che la distro WSL specificata sia disponibile
wsl -d !WSL_DISTRO! -- echo "" <nul >nul 2>&1
if errorlevel 1 (
    echo [ERRORE] La distro WSL "!WSL_DISTRO!" non e disponibile.
    echo Verifica che WSL sia installato e che il nome della distro sia corretto.
    echo Puoi cambiare il valore WSL_DISTRO nel file C:\Users\Public\lean-ctx\.env
    exit /b 1
)

:: Converti il percorso Windows in percorso WSL per i progetti e la configurazione
for /f "tokens=*" %%i in ('wsl -d !WSL_DISTRO! wslpath "%PROJECTS_DIR%" <nul') do set "wslPath=%%i"
for /f "tokens=*" %%i in ('wsl -d !WSL_DISTRO! wslpath "C:\Users\Public\lean-ctx" <nul') do set "wslConfigPath=%%i"

:: Verifica che wslPath non sia vuoto
if "!wslPath!"=="" (
    echo [ERRORE] Impossibile convertire il percorso in formato WSL: %PROJECTS_DIR%
    echo Verifica che PROJECTS_DIR nel file .env sia un percorso Windows valido.
    exit /b 1
)

:: Avvia Docker tramite WSL (usa il CMD di default che lancia loop-guard.js)
wsl -d !WSL_DISTRO! docker run -i --rm -v "!wslPath!:!wslPath!" -v "!wslConfigPath!:/root/.config/lean-ctx" -e "LEAN_CTX_DATA_DIR=/root/.config/lean-ctx" -w "!wslPath!" lean-ctx-bin-lean-ctx
