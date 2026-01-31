@echo off
REM ============================================================
REM   Print Server - Install Auto-Start (Source Version)
REM   Runs from Node.js source on user login
REM ============================================================

echo.
echo ========================================
echo   Print Server - Auto-Start Installer
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

echo [1/3] Creating startup script...

REM Create a VBS script to run Node.js silently (no console window)
set "STARTUP_SCRIPT=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\PrintServer.vbs"

(
echo Set WshShell = CreateObject^("WScript.Shell"^)
echo WshShell.Run "node ""%~dp0printServer.js""", 0, False
) > "%STARTUP_SCRIPT%"

echo [OK] Startup script created
echo.

echo [2/3] Configuring firewall...
netsh advfirewall firewall delete rule name="Print Server" >nul 2>&1
netsh advfirewall firewall add rule name="Print Server" dir=in action=allow protocol=TCP localport=9191 >nul 2>&1
echo [OK] Firewall configured
echo.

echo [3/3] Starting server now...
start /min node "%~dp0printServer.js"
timeout /t 3 /nobreak >nul
echo [OK] Server started
echo.

echo ========================================
echo   Installation Complete!
echo ========================================
echo.
echo Print Server will now start automatically when you log in.
echo.
echo Access URLs:
echo   Local:   http://localhost:9191
echo   Network: http://192.168.29.209:9191
echo.
echo To uninstall:
echo   Delete: %STARTUP_SCRIPT%
echo.
pause
