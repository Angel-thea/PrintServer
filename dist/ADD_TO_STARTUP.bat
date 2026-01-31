@echo off
echo ========================================
echo  PRINT SERVER - ADD TO STARTUP FOLDER
echo ========================================
echo.
echo This is a SIMPLE method to auto-start the server.
echo The server will run when you log in.
echo.
echo NOTE: A console window will appear on startup.
echo For background service, use INSTALL_SERVICE.bat instead.
echo.
pause

REM Get the directory where this script is located
set "SERVICE_DIR=%~dp0"
set "STARTUP_FOLDER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"

echo.
echo Creating shortcut in Startup folder...
echo.

REM Create VBScript to make shortcut
echo Set oWS = WScript.CreateObject("WScript.Shell") > "%TEMP%\CreateShortcut.vbs"
echo sLinkFile = "%STARTUP_FOLDER%\PrintServer.lnk" >> "%TEMP%\CreateShortcut.vbs"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%TEMP%\CreateShortcut.vbs"
echo oLink.TargetPath = "%SERVICE_DIR%PrintServer.exe" >> "%TEMP%\CreateShortcut.vbs"
echo oLink.WorkingDirectory = "%SERVICE_DIR%" >> "%TEMP%\CreateShortcut.vbs"
echo oLink.Description = "Print Server" >> "%TEMP%\CreateShortcut.vbs"
echo oLink.Save >> "%TEMP%\CreateShortcut.vbs"

cscript //nologo "%TEMP%\CreateShortcut.vbs"
del "%TEMP%\CreateShortcut.vbs"

echo.
echo ========================================
echo  SUCCESS!
echo ========================================
echo.
echo Print Server has been added to Startup.
echo It will start automatically when you log in to Windows.
echo.
echo Shortcut location:
echo %STARTUP_FOLDER%\PrintServer.lnk
echo.
pause
