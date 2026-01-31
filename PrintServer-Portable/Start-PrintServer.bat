@echo off
REM ============================================================
REM   Print Server - Portable Launcher
REM ============================================================

cd /d "%~dp0"

REM Check if nodejs folder exists
if not exist "nodejs\node.exe" (
    echo [ERROR] Node.js not found!
    echo.
    echo Please ensure nodejs folder is in the same directory as this script.
    echo Download from: https://nodejs.org
    pause
    exit /b 1
)

echo.
echo ========================================
echo   Starting Print Server...
echo ========================================
echo.

REM Start server in minimized window
start /min "Print Server" "%~dp0nodejs\node.exe" "%~dp0printServer.js"

echo Server is starting...
echo.
timeout /t 3 /nobreak >nul

echo ========================================
echo   Print Server Started!
echo ========================================
echo.
echo  Local:   http://localhost:9191
echo  Status:  http://localhost:9191/status
echo.
echo To stop: Run Stop-PrintServer.bat
echo.

REM Open browser
start http://localhost:9191

echo Press any key to close this window...
echo (Server will continue running in background)
pause >nul
