@echo off
REM ============================================================
REM   Print Server - Remove Auto-Start
REM ============================================================

echo.
echo ========================================
echo   Print Server - Remove Auto-Start
echo ========================================
echo.

set "STARTUP_SCRIPT=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\PrintServer.vbs"

if exist "%STARTUP_SCRIPT%" (
    echo Removing auto-start configuration...
    del "%STARTUP_SCRIPT%"
    echo.
    echo [OK] Auto-start removed successfully.
    echo.
    echo Print Server will no longer start automatically on Windows startup.
    echo You can still start it manually using Start-PrintServer.bat
) else (
    echo [INFO] Auto-start is not configured.
)

echo.
pause
