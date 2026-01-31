@echo off
echo ========================================
echo  PRINT SERVER - SERVICE STATUS
echo ========================================
echo.

set "SERVICE_DIR=%~dp0"

"%SERVICE_DIR%nssm.exe" status PrintServer

echo.
echo Service Logs Location:
echo %SERVICE_DIR%service.log
echo %SERVICE_DIR%service-error.log
echo.
echo Server URL: http://localhost:9191
echo.
pause
