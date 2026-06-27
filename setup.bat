@echo off
REM ============================================
REM  Freebuff Looping - SETUP (Windows)
REM  Run once to configure worktrees & workers
REM ============================================

setlocal enabledelayedexpansion

set "PROJECT_ROOT=%~dp0"
set "PROJECT_ROOT=%PROJECT_ROOT:~0,-1%"

for %%I in ("%PROJECT_ROOT%") do set "PROJECT_NAME=%%~nI"
for %%I in ("%PROJECT_ROOT%") do set "PARENT_DIR=%%~dpI"

echo =============================================
echo   Freebuff Looping - SETUP
echo =============================================
echo.
echo Project: %PROJECT_NAME%
echo Root:    %PROJECT_ROOT%
echo Parent:  %PARENT_DIR%
echo.

REM Step 1: Init git if needed
if not exist "%PROJECT_ROOT%\.git" (
    echo [1/5] Initializing git repo...
    cd /d "%PROJECT_ROOT%"
    git init
    git checkout -b main
) else (
    echo [1/5] Git repo exists - skipping init.
)

REM Step 2: Create initial commit if needed
cd /d "%PROJECT_ROOT%"
git rev-parse HEAD >nul 2>&1
if errorlevel 1 (
    echo [2/5] Creating initial commit...
    git add -A
    git commit -m "Initial commit (freebuff-looping setup)"
) else (
    echo [2/5] Git commit exists - skipping."
)

REM Step 3: Create worktrees
set "WT1=%PARENT_DIR%%PROJECT_NAME%-w1"
set "WT2=%PARENT_DIR%%PROJECT_NAME%-w2"

echo [3/5] Creating worktrees...

git worktree list 2>nul | findstr /C:"%PROJECT_NAME%-w1" >nul
if errorlevel 1 (
    echo   - Creating worker-1 worktree...
    git worktree add -b worker-1 "%WT1%" main
) else (
    echo   - Worktree worker-1 already exists.
)

git worktree list 2>nul | findstr /C:"%PROJECT_NAME%-w2" >nul
if errorlevel 1 (
    echo   - Creating worker-2 worktree...
    git worktree add -b worker-2 "%WT2%" main
) else (
    echo   - Worktree worker-2 already exists.
)

REM Step 4: Create config directories
echo [4/5] Setting up worker config directories...

if not exist "%USERPROFILE%\.config\manicode-w1" (
    mkdir "%USERPROFILE%\.config\manicode-w1"
)
if not exist "%USERPROFILE%\.config\manicode-w2" (
    mkdir "%USERPROFILE%\.config\manicode-w2"
)

REM Copy credentials
if exist "%USERPROFILE%\.config\manicode\credentials.json" (
    copy /Y "%USERPROFILE%\.config\manicode\credentials.json" "%USERPROFILE%\.config\manicode-w1\" >nul
    copy /Y "%USERPROFILE%\.config\manicode\credentials.json" "%USERPROFILE%\.config\manicode-w2\" >nul
    echo   - Credentials copied to worker configs.
) else (
    echo   - WARNING: No credentials found. You'll need to login in each worker.
)

REM Step 5: Done
echo [5/5] Setup complete!
echo.
echo =============================================
echo   SETUP SELESAI! Cara mulai:
echo.
echo   Orchestrator:  start-orchestrator.bat
echo   Worker 1:      start-worker1.bat
echo   Worker 2:      start-worker2.bat
echo =============================================
echo.

pause
endlocal
