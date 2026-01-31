@echo off
echo ========================================
echo  PRINT SERVER - SERVICE INSTALLER
echo ========================================
echo.
echo This will install Print Server as a Windows Service
echo that starts automatically on boot.
echo.
echo IMPORTANT: Run this script as Administrator!
echo.
pause

REM Get the directory where this script is located
set "SERVICE_DIR=%~dp0"
set "EXE_PATH=%SERVICE_DIR%PrintServer.exe"

echo.
echo Installing NSSM (Service Manager)...
echo.

REM Download NSSM if not present
if not exist "%SERVICE_DIR%nssm.exe" (
    echo Downloading NSSM...
    powershell -Command "& {Invoke-WebRequest -Uri 'https://nssm.cc/ci/nssm-2.24-101-g897c7ad.zip' -OutFile '%SERVICE_DIR%nssm.zip'}"
    powershell -Command "& {Expand-Archive -Path '%SERVICE_DIR%nssm.zip' -DestinationPath '%SERVICE_DIR%nssm_temp' -Force}"
    copy "%SERVICE_DIR%nssm_temp\nssm-2.24-101-g897c7ad\win64\nssm.exe" "%SERVICE_DIR%nssm.exe"
    rmdir /s /q "%SERVICE_DIR%nssm_temp"
    del "%SERVICE_DIR%nssm.zip"
    echo NSSM downloaded successfully.
) else (
    echo NSSM already present.
)

echo.
echo Installing Print Server as Windows Service...
echo.

REM Stop and remove existing service if it exists
"%SERVICE_DIR%nssm.exe" stop PrintServer >nul 2>&1
"%SERVICE_DIR%nssm.exe" remove PrintServer confirm >nul 2>&1

REM Install the service
"%SERVICE_DIR%nssm.exe" install PrintServer "%EXE_PATH%"

REM Configure service
"%SERVICE_DIR%nssm.exe" set PrintServer AppDirectory "%SERVICE_DIR%"
"%SERVICE_DIR%nssm.exe" set PrintServer DisplayName "Print Server"
"%SERVICE_DIR%nssm.exe" set PrintServer Description "Thermal Printer Server with Logo Support"
"%SERVICE_DIR%nssm.exe" set PrintServer Start SERVICE_AUTO_START
"%SERVICE_DIR%nssm.exe" set PrintServer AppRestartDelay 5000
"%SERVICE_DIR%nssm.exe" set PrintServer AppStdout "%SERVICE_DIR%service.log"
"%SERVICE_DIR%nssm.exe" set PrintServer AppStderr "%SERVICE_DIR%service-error.log"

echo.
echo Starting service...
"%SERVICE_DIR%nssm.exe" start PrintServer

echo.
echo ========================================
echo  INSTALLATION COMPLETE!
echo ========================================
echo.
echo Service Name: PrintServer
echo Status: Running
echo Startup Type: Automatic (starts on boot)
echo.
echo The server is now running in the background.
echo It will automatically start when Windows boots.
echo.
echo Logs are saved to:
echo   - %SERVICE_DIR%service.log
echo   - %SERVICE_DIR%service-error.log
echo.
echo To verify: http://localhost:9191
echo.
pause
