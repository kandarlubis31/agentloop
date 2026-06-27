@echo off
REM ============================================
REM  Freebuff Looping - Takeover Test (Windows)
REM  Double-click to verify takeover bypass
REM ============================================

setlocal

set "BASE=%~dp0"
set "BASE=%BASE:~0,-1%"

for %%I in ("%BASE%") do set "PROJECT_NAME=%%~nI"
for %%I in ("%BASE%") do set "PARENT_DIR=%%~dpI"

set "CONFIG_W1=%USERPROFILE%\.config\manicode-w1"

echo =============================================
echo   Freebuff Looping - HOME Override Test
echo =============================================
echo.

echo [1] Setup config worker...
if not exist "%CONFIG_W1%\.config\manicode" (
    mkdir "%CONFIG_W1%\.config\manicode"
)
if exist "%USERPROFILE%\.config\manicode\credentials.json" (
    copy /Y "%USERPROFILE%\.config\manicode\credentials.json" "%CONFIG_W1%\.config\manicode\" >nul
)
echo     Config worker siap di: %CONFIG_W1%
echo.

echo [2] BUKA TERMINAL BARU (jangan tutup ini!)
echo.
echo     Ketik ini di terminal baru:
echo     +------------------------------------------------------+
echo     ^| cd "%PARENT_DIR%%PROJECT_NAME%-w1"                    ^|
echo     ^| set USERPROFILE=%CONFIG_W1%                            ^|
echo     ^| freebuff                                              ^|
echo     +------------------------------------------------------+
echo.
echo [3] HARUSNYA worker jalan TANPA takeover!
echo     [OK] Session baru -^> BERHASIL
echo     [XX] Takeover -^> GAGAL
echo.
echo [4] Di worker, ketik:
echo     'Tulis hello dari worker HOME override ke test-loop.txt'
echo.
echo [5] Di orchestrator (INI), ketik:
echo     'Baca test-loop.txt dan verifikasi isinya'
echo.
echo =============================================
echo   Kalau worker jalan tanpa takeover
echo   -^> HOME OVERRIDE BERHASIL BYPASS LOCK!
echo =============================================
echo.

pause
endlocal
