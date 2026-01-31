@echo off
echo ========================================
echo  PRINT SERVER - SERVICE UNINSTALLER
echo ========================================
echo.
echo This will remove Print Server from Windows Services.
echo.
echo IMPORTANT: Run this script as Administrator!
echo.
pause

REM Get the directory where this script is located
set "SERVICE_DIR=%~dp0"

echo.
echo Stopping service...
"%SERVICE_DIR%nssm.exe" stop PrintServer

echo.
echo Removing service...
"%SERVICE_DIR%nssm.exe" remove PrintServer confirm

echo.
echo ========================================
echo  UNINSTALLATION COMPLETE!
echo ========================================
echo.
echo The Print Server service has been removed.
echo.
pause
