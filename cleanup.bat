@echo off
REM ============================================
REM  Freebuff Looping - CLEANUP (Windows)
REM  Remove worktrees, config dirs, branches
REM ============================================

setlocal enabledelayedexpansion

set "PROJECT_ROOT=%~dp0"
set "PROJECT_ROOT=%PROJECT_ROOT:~0,-1%"

for %%I in ("%PROJECT_ROOT%") do set "PROJECT_NAME=%%~nI"
for %%I in ("%PROJECT_ROOT%") do set "PARENT_DIR=%%~dpI"

echo =============================================
echo   Freebuff Looping - CLEANUP
echo =============================================
echo.
echo This will remove:
echo   - Worktrees: %PROJECT_NAME%-w1, %PROJECT_NAME%-w2
echo   - Branches: worker-1, worker-2
echo   - Config dirs: manicode-w1, manicode-w2
echo   - Runtime files: queue/*.json, results/*.json
echo.

set /p "confirm=Continue? (y/N): "
if /i not "%confirm%"=="y" (
    echo Aborted.
    pause
    exit /b 0
)

cd /d "%PROJECT_ROOT%"

REM Remove worktrees
echo.
echo [1/3] Removing worktrees...

set "WT1=%PARENT_DIR%%PROJECT_NAME%-w1"
set "WT2=%PARENT_DIR%%PROJECT_NAME%-w2"

git worktree list 2>nul | findstr /C:"%PROJECT_NAME%-w1" >nul 2>&1
if not errorlevel 1 (
    echo   - Removing %PROJECT_NAME%-w1...
    git worktree remove "%WT1%" 2>nul || git worktree remove --force "%WT1%" 2>nul
)
if exist "%WT1%" (
    rmdir /s /q "%WT1%" 2>nul
    echo     Cleaned leftover directory.
)

git worktree list 2>nul | findstr /C:"%PROJECT_NAME%-w2" >nul 2>&1
if not errorlevel 1 (
    echo   - Removing %PROJECT_NAME%-w2...
    git worktree remove "%WT2%" 2>nul || git worktree remove --force "%WT2%" 2>nul
)
if exist "%WT2%" (
    rmdir /s /q "%WT2%" 2>nul
    echo     Cleaned leftover directory.
)

REM Remove branches
echo [2/3] Removing branches...
git branch -D worker-1 2>nul
git branch -D worker-2 2>nul

REM Remove config dirs
echo [3/3] Removing worker config dirs...
rmdir /s /q "%USERPROFILE%\.config\manicode-w1" 2>nul
rmdir /s /q "%USERPROFILE%\.config\manicode-w2" 2>nul

REM Clean runtime files
echo     Cleaning queue/results/in-progress...
del /q "%PROJECT_ROOT%\queue\*.json" 2>nul
del /q "%PROJECT_ROOT%\results\*.json" 2>nul
del /q "%PROJECT_ROOT%\in-progress\*.json" 2>nul

echo.
echo =============================================
echo   CLEANUP COMPLETE!
echo =============================================
echo.

pause
endlocal
