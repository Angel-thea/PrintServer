@echo off
REM ============================================================
REM   Print Server - Stop Script
REM ============================================================

echo.
echo ========================================
echo   Stopping Print Server...
echo ========================================
echo.

REM Kill all node processes with "Print Server" in window title
taskkill /F /FI "WINDOWTITLE eq Print Server*" >nul 2>&1

if %errorlevel% EQU 0 (
    echo [OK] Print Server stopped successfully.
) else (
    echo [INFO] Print Server was not running.
)

echo.
timeout /t 2
