@echo off
REM ============================================
REM  AgentLoop - RUN ALL (One-Click!)
REM  Opens 3 CMD windows: Orchestrator + 2 Workers
REM  Usage: run-all.bat (double-click!)
REM ============================================

setlocal enabledelayedexpansion

set "PROJECT_ROOT=%~dp0"
set "PROJECT_ROOT=%PROJECT_ROOT:~0,-1%"

for %%I in ("%PROJECT_ROOT%") do set "PROJECT_NAME=%%~nI"
for %%I in ("%PROJECT_ROOT%") do set "PARENT_DIR=%%~dpI"

set "WT1=%PARENT_DIR%%PROJECT_NAME%-w1"
set "WT2=%PARENT_DIR%%PROJECT_NAME%-w2"

REM Check freebuff
where freebuff >nul 2>&1
if errorlevel 1 (
    echo [ERROR] freebuff not found in PATH!
    pause
    exit /b 1
)

REM Check worktrees
if not exist "%WT1%" (
    echo [ERROR] Worktree not found: %WT1%
    echo         Run setup.bat first!
    pause
    exit /b 1
)

echo =============================================
echo   AgentLoop - RUN ALL
echo =============================================
echo.
echo   Opening 3 windows:
echo   [1] Orchestrator  (normal config)
echo   [2] Worker 1      (manicode-w1 config)
echo   [3] Worker 2      (manicode-w2 config)
echo.
echo   TIP: Arrange windows side-by-side!
echo   ┌──────────┬──────────┬──────────┐
echo   │   ORCH   │  WORKER1 │  WORKER2 │
echo   └──────────┴──────────┴──────────┘
echo.
echo   Each window will show instructions.
echo   Copy-paste the appropriate prompt file.
echo =============================================
echo.
echo Starting in 3 seconds...
timeout /t 3 /nobreak >nul

REM Window 1: Orchestrator (normal config)
start "ORCHESTRATOR - AgentLoop" /D "%PROJECT_ROOT%" cmd /k ^
"echo ===== ORCHESTRATOR ===== && ^
echo Config: %%USERPROFILE%%\.config\manicode (normal) && ^
echo. && ^
echo COPY-PASTE isi orchestrator-prompt.md && ^
echo LALU kasih task besar ke orchestrator! && ^
echo. && ^
freebuff"

REM Small delay so windows don't stack
timeout /t 1 /nobreak >nul

REM Window 2: Worker 1 (HOME override)
start "WORKER 1 - AgentLoop" /D "%WT1%" cmd /k ^
"set USERPROFILE=%%USERPROFILE%%\.config\manicode-w1 && ^
set HOME=%%USERPROFILE%%\.config\manicode-w1 && ^
echo ===== WORKER 1 ===== && ^
echo Config: %%USERPROFILE%% && ^
echo. && ^
echo COPY-PASTE isi worker-prompt.md && ^
echo Worker akan auto-scan queue/ ^& eksekusi! && ^
echo. && ^
freebuff"

timeout /t 1 /nobreak >nul

REM Window 3: Worker 2 (HOME override)
start "WORKER 2 - AgentLoop" /D "%WT2%" cmd /k ^
"set USERPROFILE=%%USERPROFILE%%\.config\manicode-w2 && ^
set HOME=%%USERPROFILE%%\.config\manicode-w2 && ^
echo ===== WORKER 2 ===== && ^
echo Config: %%USERPROFILE%% && ^
echo. && ^
echo COPY-PASTE isi worker-prompt.md && ^
echo Worker akan auto-scan queue/ ^& eksekusi! && ^
echo. && ^
freebuff"

echo.
echo All 3 windows launched! Check your taskbar.
echo.
echo TIP: Press Win+Left/Right to snap windows.
echo.

endlocal
