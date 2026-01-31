@echo off
REM ============================================================
REM   Print Server - Quick Deployment Script
REM   Copy this folder to target device and run this script
REM ============================================================

echo.
echo ========================================
echo   Print Server - Quick Deployment
echo ========================================
echo.

REM Check for admin rights
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo [ERROR] This script requires Administrator privileges!
    echo Please right-click and select "Run as Administrator"
    echo.
    pause
    exit /b 1
)

echo [1/4] Checking files...
if not exist "%~dp0PrintServer.exe" (
    echo [ERROR] PrintServer.exe not found!
    echo Please run this script from the dist folder.
    pause
    exit /b 1
)

if not exist "%~dp0sharp" (
    echo [WARNING] sharp folder not found!
    echo Logo conversion may not work.
    timeout /t 3
)

echo [OK] Files found
echo.

echo [2/4] Checking for existing installation...
sc query PrintServer >nul 2>&1
if %errorLevel% EQU 0 (
    echo [WARNING] Print Server service already exists!
    echo Please uninstall first using UNINSTALL_SERVICE.bat
    pause
    exit /b 1
)

echo [OK] No conflicts detected
echo.

echo [3/4] Choose installation method:
echo.
echo 1. Quick Start (Manual mode - for testing)
echo 2. Auto-Start on Login (Recommended for workstations)
echo 3. Windows Service (Recommended for servers)
echo 4. Exit
echo.

choice /C 1234 /N /M "Select option (1-4): "

if errorlevel 4 exit /b 0
if errorlevel 3 goto SERVICE
if errorlevel 2 goto AUTOSTART
if errorlevel 1 goto MANUAL

:MANUAL
echo.
echo [4/4] Starting Print Server in manual mode...
echo Press Ctrl+C to stop the server
echo.
timeout /t 2
start "Print Server" "%~dp0PrintServer.exe"
echo.
echo Server started! Opening status page...
timeout /t 3
start http://localhost:9191/status
echo.
echo Server is running in the background window.
echo Close that window to stop the server.
pause
exit /b 0

:AUTOSTART
echo.
echo [4/4] Installing auto-start on login...
call "%~dp0INSTALL_AUTO_START.bat"
pause
exit /b 0

:SERVICE
echo.
echo [4/4] Installing as Windows Service...
call "%~dp0INSTALL_SERVICE.bat"
pause
exit /b 0
