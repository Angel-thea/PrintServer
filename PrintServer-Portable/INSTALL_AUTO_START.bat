@echo off
REM ============================================================
REM   Print Server - Install Auto-Start on Windows Startup
REM ============================================================

echo.
echo ========================================
echo   Print Server - Auto-Start Installer
echo ========================================
echo.

REM Get the current directory where PrintServer is located
set "SERVER_PATH=%~dp0"

echo This will configure Print Server to start automatically when Windows starts.
echo.
echo Server Location: %SERVER_PATH%
echo.
pause

REM Create VBScript to run server silently (no console window)
set "STARTUP_SCRIPT=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\PrintServer.vbs"

echo Creating startup script...

(
echo Set WshShell = CreateObject^("WScript.Shell"^)
echo WshShell.Run """%SERVER_PATH%nodejs\node.exe"" ""%SERVER_PATH%printServer.js""", 0, False
) > "%STARTUP_SCRIPT%"

echo.
echo ========================================
echo   Installation Complete!
echo ========================================
echo.
echo Print Server will now start automatically when you log in to Windows.
echo.
echo The server will run in the background (no console window).
echo.
echo To verify:
echo   1. Restart your computer or log out and log back in
echo   2. Open browser: http://localhost:9191
echo   3. Should see "Print Service with Logo Support is running"
echo.
echo To uninstall auto-start:
echo   Run: UNINSTALL_AUTO_START.bat
echo.
pause
