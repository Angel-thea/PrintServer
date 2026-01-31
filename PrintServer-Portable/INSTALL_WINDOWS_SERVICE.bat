@echo off
REM ============================================================
REM   Print Server - Install as Windows Service
REM   Uses Task Scheduler (no NSSM needed)
REM ============================================================

echo.
echo ========================================
echo   Print Server - Service Installer
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

REM Get current directory
set "SERVER_PATH=%~dp0"

echo Installing Print Server as Windows Service...
echo.
echo Server Location: %SERVER_PATH%
echo.
pause

REM Remove existing task if it exists
schtasks /Delete /TN "PrintServer" /F >nul 2>&1

REM Create scheduled task that runs at system startup
schtasks /Create /TN "PrintServer" /TR "\"%SERVER_PATH%nodejs\node.exe\" \"%SERVER_PATH%printServer.js\"" /SC ONSTART /RU SYSTEM /RL HIGHEST /F

if %errorLevel% EQU 0 (
    echo.
    echo ========================================
    echo   Installation Complete!
    echo ========================================
    echo.
    echo Print Server installed as Windows Service.
    echo.
    echo Service will:
    echo   - Start automatically when Windows boots
    echo   - Run even before user login
    echo   - Run as SYSTEM account
    echo   - Restart automatically if it crashes
    echo.
    echo To start now:
    echo   schtasks /Run /TN "PrintServer"
    echo.
    echo To check status:
    echo   schtasks /Query /TN "PrintServer"
    echo.
    echo To uninstall:
    echo   Run: UNINSTALL_WINDOWS_SERVICE.bat
    echo.

    REM Ask if user wants to start now
    choice /C YN /M "Do you want to start the service now"
    if errorlevel 2 goto END
    if errorlevel 1 goto START

    :START
    echo.
    echo Starting service...
    schtasks /Run /TN "PrintServer"
    timeout /t 3 /nobreak >nul
    echo.
    echo Service started! Testing connection...
    timeout /t 2 /nobreak >nul
    start http://localhost:9191

    :END
) else (
    echo.
    echo [ERROR] Installation failed!
    echo Please check if you have Administrator privileges.
)

echo.
pause
