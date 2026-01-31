@echo off
REM ============================================================
REM   Create Portable Print Server Bundle
REM   This creates a standalone folder that works on any Windows PC
REM ============================================================

echo.
echo ========================================
echo   Creating Portable Bundle
echo ========================================
echo.

set "BUNDLE_DIR=PrintServer-Portable"
set "NODE_VERSION=20.11.0"

echo [1/6] Creating bundle directory...
if exist "%BUNDLE_DIR%" rmdir /s /q "%BUNDLE_DIR%"
mkdir "%BUNDLE_DIR%"
echo [OK] Directory created
echo.

echo [2/6] Copying application files...
xcopy /E /I /Y "node_modules" "%BUNDLE_DIR%\node_modules\"
copy /Y "printServer.js" "%BUNDLE_DIR%\"
copy /Y "package.json" "%BUNDLE_DIR%\"
echo [OK] Application files copied
echo.

echo [3/6] Downloading Node.js portable...
echo This requires Node.js portable or you can download manually from:
echo https://nodejs.org/dist/v%NODE_VERSION%/node-v%NODE_VERSION%-win-x64.zip
echo.
echo After downloading, extract it to: %BUNDLE_DIR%\nodejs\
echo.
pause

echo [4/6] Creating launcher script...
(
echo @echo off
echo cd /d "%%~dp0"
echo start /min "Print Server" "%%~dp0nodejs\node.exe" printServer.js
echo echo Print Server is starting...
echo timeout /t 3 /nobreak ^>nul
echo start http://localhost:9191
echo exit
) > "%BUNDLE_DIR%\Start-PrintServer.bat"

(
echo @echo off
echo taskkill /F /FI "WINDOWTITLE eq Print Server*" ^>nul 2^>^&1
echo echo Print Server stopped.
echo timeout /t 2
) > "%BUNDLE_DIR%\Stop-PrintServer.bat"

echo [OK] Launcher created
echo.

echo [5/6] Creating README...
(
echo ================================================================================
echo                   PRINT SERVER - PORTABLE VERSION
echo ================================================================================
echo.
echo This is a portable version that runs on any Windows PC without installation.
echo.
echo REQUIREMENTS:
echo   - Windows 7/8/10/11 ^(64-bit^)
echo   - Thermal printer with driver installed
echo.
echo HOW TO RUN:
echo   1. Double-click: Start-PrintServer.bat
echo   2. Wait for browser to open
echo   3. Server is now running on http://localhost:9191
echo.
echo HOW TO STOP:
echo   - Double-click: Stop-PrintServer.bat
echo.
echo PRINTER CONFIGURATION:
echo   - Default printer: RP3160
echo   - To change: Edit printServer.js line 27
echo.
echo NETWORK ACCESS:
echo   - Allow port 9191 in Windows Firewall when prompted
echo   - Access from other devices: http://[PC-IP]:9191
echo.
echo ================================================================================
) > "%BUNDLE_DIR%\README.txt"

echo [OK] README created
echo.

echo [6/6] Next steps...
echo.
echo ========================================
echo   Manual Step Required
echo ========================================
echo.
echo Please download Node.js portable:
echo   1. Go to: https://nodejs.org/dist/v%NODE_VERSION%/node-v%NODE_VERSION%-win-x64.zip
echo   2. Extract the ZIP file
echo   3. Copy the extracted folder to: %BUNDLE_DIR%\nodejs\
echo   4. The folder should contain: node.exe, npm, etc.
echo.
echo After completing this step, the %BUNDLE_DIR% folder will be
echo ready to copy to any Windows PC!
echo.
echo ========================================
pause
