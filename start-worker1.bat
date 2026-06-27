@echo off
REM ============================================
REM  Freebuff Looping - Worker 1 Launcher
REM  Double-click to start worker 1 session
REM ============================================

setlocal

REM Detect project root (where this .bat lives)
set "PROJECT_ROOT=%~dp0"
set "PROJECT_ROOT=%PROJECT_ROOT:~0,-1%"

REM Derive worktree path (sibling folder with -w1 suffix)
for %%I in ("%PROJECT_ROOT%") do set "PARENT_DIR=%%~dpI"
for %%I in ("%PROJECT_ROOT%") do set "PROJECT_NAME=%%~nI"
set "WORKTREE_DIR=%PARENT_DIR%%PROJECT_NAME%-w1"

REM HOME override = bypass takeover!
set "HOME=%USERPROFILE%\.config\manicode-w1"

echo =============================================
echo   Freebuff Looping - WORKER 1
echo =============================================
echo.
echo Project:  %WORKTREE_DIR%
echo Config:   %HOME%
echo Mode:     Worker 1 (task execution)
echo.
echo =============================================
echo   COPY-PASTE isi worker-prompt.md
echo   Worker akan auto-scan queue/ & eksekusi!
echo =============================================
echo.

if not exist "%WORKTREE_DIR%" (
    echo [ERROR] Worktree folder not found: %WORKTREE_DIR%
    echo         Run setup.bat first!
    pause
    exit /b 1
)

cd /d "%WORKTREE_DIR%"
freebuff

endlocal
