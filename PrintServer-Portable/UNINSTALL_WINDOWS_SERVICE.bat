@echo off
REM ============================================================
REM   Print Server - Uninstall Windows Service
REM ============================================================

echo.
echo ========================================
echo   Print Server - Service Uninstaller
echo ========================================
echo.

REM Check for admin rights
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo [ERROR] This requires Administrator privileges!
    echo.
    echo Please right-click this file and select "Run as Administrator"
    echo.
    pause
    exit /b 1
)

echo Removing Print Server service...
echo.

REM Stop and delete the task
schtasks /End /TN "PrintServer" >nul 2>&1
schtasks /Delete /TN "PrintServer" /F

if %errorLevel% EQU 0 (
    echo [OK] Service removed successfully.
    echo.
    echo Print Server will no longer start automatically.
    echo.
    echo You can still start it manually using Start-PrintServer.bat
) else (
    echo [INFO] Service was not installed or already removed.
)

echo.
pause
