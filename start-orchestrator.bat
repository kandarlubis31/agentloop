@echo off
REM ============================================
REM  AgentLoop - Orchestrator Launcher
REM  Double-click to start orchestrator session
REM ============================================

setlocal

REM Prerequisite check
where freebuff >nul 2>&1
if errorlevel 1 (
    echo [ERROR] freebuff not found in PATH!
    echo         Install: npm install -g freebuff
    pause
    exit /b 1
)

REM Detect project root (where this .bat lives)
set "PROJECT_ROOT=%~dp0"
set "PROJECT_ROOT=%PROJECT_ROOT:~0,-1%"

echo =============================================
echo   AgentLoop - ORCHESTRATOR
echo =============================================
echo.
echo Project: %PROJECT_ROOT%
echo Config:  %%USERPROFILE%%\.config\manicode
echo Mode:    Orchestrator (planning & monitoring)
echo.
echo =============================================
echo   COPY-PASTE isi orchestrator-prompt.md
echo   LALU kasih task besar ke orchestrator!
echo =============================================
echo.
echo Starting in 3 seconds...

REM Let user read the banner before TUI clears screen
timeout /t 3 /nobreak >nul

cd /d "%PROJECT_ROOT%"
freebuff

endlocal
