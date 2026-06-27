@echo off
REM ============================================
REM  Freebuff Looping - Orchestrator Launcher
REM  Double-click to start orchestrator session
REM ============================================

setlocal

REM Detect project root (where this .bat lives)
set "PROJECT_ROOT=%~dp0"
set "PROJECT_ROOT=%PROJECT_ROOT:~0,-1%"

echo =============================================
echo   Freebuff Looping - ORCHESTRATOR
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

cd /d "%PROJECT_ROOT%"
freebuff

endlocal
