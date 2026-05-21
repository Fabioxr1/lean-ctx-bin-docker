@echo off
setlocal enabledelayedexpansion

:: Default PROJECTS_DIR
set "PROJECTS_DIR=C:\Users\Feedweb F\Desktop\progetti"

:: Load PROJECTS_DIR from .env if it exists
if exist "C:\Users\Public\lean-ctx\.env" (
    for /f "usebackq delims== tokens=1,*" %%a in ("C:\Users\Public\lean-ctx\.env") do (
        set "KEY=%%a"
        set "VAL=%%b"
        if "!KEY!"=="PROJECTS_DIR" (
            set "PROJECTS_DIR=!VAL!"
        )
    )
)

:: Trim trailing spaces from PROJECTS_DIR if any
:trim
if "!PROJECTS_DIR:~-1!"==" " (
    set "PROJECTS_DIR=!PROJECTS_DIR:~0,-1!"
    goto trim
)

:: Get WSL path (redirect stdin to nul to prevent consuming piped input)
for /f "tokens=*" %%i in ('wsl -d Ubuntu wslpath "%PROJECTS_DIR%" ^<nul') do set "wslPath=%%i"

:: Start WSL with docker
wsl -d Ubuntu docker run -i --rm -v "%wslPath%:%wslPath%" -v "lean-ctx-bin_lean_ctx_data:/root/.config/lean-ctx" -e "LEAN_CTX_DATA_DIR=/root/.config/lean-ctx" -w "%wslPath%" lean-ctx-bin-lean-ctx lean-ctx
