@echo off
echo ========================================
echo  PRINT SERVER - PROFESSIONAL INSTALLER
echo ========================================
echo.
echo This will launch the Print Server installer.
echo.
echo Features:
echo  - Installs to Program Files
echo  - Auto-starts on boot
echo  - Configures firewall
echo  - Creates Start Menu shortcuts
echo  - Professional installation
echo.
echo IMPORTANT: You will be prompted for Administrator access.
echo.
pause

PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0PrintServerInstaller.ps1'"

pause
