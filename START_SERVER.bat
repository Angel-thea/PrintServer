@echo off
REM ============================================================
REM   Print Server - Simple Startup Script
REM ============================================================

echo.
echo ========================================
echo   Starting Print Server...
echo ========================================
echo.

cd /d "%~dp0"
node printServer.js

pause
