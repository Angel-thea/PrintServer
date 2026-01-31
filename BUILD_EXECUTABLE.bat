@echo off
REM ============================================================
REM   Print Server - Build Executable/Installer
REM   This script helps you create a standalone installer
REM ============================================================

echo.
echo ========================================
echo   Print Server - Build Menu
echo ========================================
echo.
echo Choose what to build:
echo.
echo 1. Portable Bundle (Recommended - Works on any PC)
echo 2. Inno Setup Installer (.exe installer)
echo 3. ZIP Package (for manual distribution)
echo 4. Exit
echo.

choice /C 1234 /N /M "Select option (1-4): "

if errorlevel 4 exit /b 0
if errorlevel 3 goto ZIP
if errorlevel 2 goto INNO
if errorlevel 1 goto PORTABLE

:PORTABLE
echo.
echo ========================================
echo   Building Portable Bundle
echo ========================================
echo.
echo This will create a standalone folder with:
echo   - Node.js runtime (portable)
echo   - Print Server application
echo   - All dependencies
echo   - Launcher scripts
echo.
echo The bundle will work on any Windows PC without installation!
echo.
pause

PowerShell.exe -ExecutionPolicy Bypass -File "%~dp0Build-PortableBundle.ps1"

echo.
echo Build complete! Check the PrintServer-Portable folder.
pause
exit /b 0

:INNO
echo.
echo ========================================
echo   Building Inno Setup Installer
echo ========================================
echo.
echo Requirements:
echo   1. Inno Setup must be installed
echo      Download from: https://jrsoftware.org/isinfo.php
echo.
echo   2. Run Build Portable Bundle first (option 1)
echo.
echo   3. Open installer-script.iss with Inno Setup Compiler
echo.
echo   4. Click "Compile" to create the installer
echo.
echo This will create: PrintServer-Setup.exe
echo.
pause
exit /b 0

:ZIP
echo.
echo ========================================
echo   Creating ZIP Package
echo ========================================
echo.
echo Creating ZIP package...

PowerShell.exe -Command "Compress-Archive -Path 'PrintServer-Portable\*' -DestinationPath 'PrintServer-Portable.zip' -Force"

if exist "PrintServer-Portable.zip" (
    echo.
    echo [OK] ZIP package created: PrintServer-Portable.zip
    echo.
    echo You can now distribute this ZIP file.
    echo Users just extract and run Start-PrintServer.bat
) else (
    echo.
    echo [ERROR] Failed to create ZIP package.
    echo Please build the Portable Bundle first (option 1^)
)

echo.
pause
exit /b 0
