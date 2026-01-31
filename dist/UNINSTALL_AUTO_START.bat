@echo off
echo ========================================
echo  PRINT SERVER - UNINSTALLER
echo ========================================
echo.
echo This will remove Print Server from auto-start.
echo.
echo IMPORTANT: Run this script as Administrator!
echo.
pause

echo.
echo Stopping Print Server...
taskkill /F /IM PrintServer.exe >nul 2>&1

echo Removing scheduled task...
schtasks /Delete /TN "PrintServer" /F

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo  UNINSTALLATION COMPLETE!
    echo ========================================
    echo.
    echo Print Server has been removed from auto-start.
    echo.
) else (
    echo.
    echo No scheduled task found or removal failed.
    echo.
)

pause
