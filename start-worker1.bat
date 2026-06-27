@echo off
REM ============================================
REM  Freebuff Looping - Worker 1 Launcher
REM  Double-click to start worker 1 session
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

REM Derive worktree path (sibling folder with -w1 suffix)
for %%I in ("%PROJECT_ROOT%") do set "PARENT_DIR=%%~dpI"
for %%I in ("%PROJECT_ROOT%") do set "PROJECT_NAME=%%~nI"
set "WORKTREE_DIR=%PARENT_DIR%%PROJECT_NAME%-w1"

REM Override config path = bypass takeover!
REM Node.js os.homedir() reads USERPROFILE on Windows
set "USERPROFILE=%USERPROFILE%\.config\manicode-w1"
set "HOME=%USERPROFILE%\.config\manicode-w1"

echo =============================================
echo   Freebuff Looping - WORKER 1
echo =============================================
echo.
echo Project:  %WORKTREE_DIR%
echo Config:   %USERPROFILE%
echo Mode:     Worker 1 (task execution)
echo.
echo =============================================
echo   COPY-PASTE isi worker-prompt.md
echo   Worker akan auto-scan queue/ & eksekusi!
echo =============================================
echo.
echo Starting in 3 seconds...

REM Let user read the banner before TUI clears screen
timeout /t 3 /nobreak >nul

if not exist "%WORKTREE_DIR%" (
    echo [ERROR] Worktree folder not found: %WORKTREE_DIR%
    echo         Run setup.bat first!
    pause
    exit /b 1
)

cd /d "%WORKTREE_DIR%"
freebuff

endlocal
