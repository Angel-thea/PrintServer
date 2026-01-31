@echo off
echo ========================================
echo  PRINT SERVER - MANUAL START
echo ========================================
echo.
echo Starting Print Server...
echo The server will run in this window.
echo.
echo Server will be available at:
echo   Local:   http://localhost:9191
echo   Network: http://192.168.29.209:9191
echo.
echo Press Ctrl+C to stop the server
echo ========================================
echo.

cd /d "%~dp0"
PrintServer.exe
