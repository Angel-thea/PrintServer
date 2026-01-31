@echo off
echo ========================================
echo  PRINT SERVER - AUTO-START INSTALLER
echo ========================================
echo.
echo This will configure Print Server to start automatically
echo on boot using Windows Task Scheduler (built-in).
echo.
echo IMPORTANT: Run this script as Administrator!
echo.
pause

REM Get the directory where this script is located
set "SERVICE_DIR=%~dp0"
set "EXE_PATH=%SERVICE_DIR%PrintServer.exe"

echo.
echo Installing Print Server to start on boot...
echo.

REM Delete existing task if it exists
schtasks /Delete /TN "PrintServer" /F >nul 2>&1

REM Create scheduled task to run at startup
schtasks /Create /TN "PrintServer" /TR "\"%EXE_PATH%\"" /SC ONSTART /RU "SYSTEM" /RL HIGHEST /F

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo  INSTALLATION COMPLETE!
    echo ========================================
    echo.
    echo Task Name: PrintServer
    echo Startup Type: Automatic ^(runs on boot^)
    echo Run As: SYSTEM ^(background service^)
    echo.
    echo The server will start automatically when Windows boots.
    echo.
    echo Starting server now...
    schtasks /Run /TN "PrintServer"
    echo.
    echo Wait 5 seconds for server to start...
    timeout /t 5 /nobreak >nul
    echo.
    echo Testing server...
    powershell -Command "try { Invoke-WebRequest -Uri 'http://localhost:9191' -UseBasicParsing -TimeoutSec 3 | Out-Null; Write-Host 'SUCCESS: Server is running!' -ForegroundColor Green; Write-Host 'Access at: http://localhost:9191' -ForegroundColor Cyan; Write-Host 'Network IP: http://192.168.29.209:9191' -ForegroundColor Cyan } catch { Write-Host 'Server starting... check http://localhost:9191 in a moment' -ForegroundColor Yellow }"
    echo.
) else (
    echo.
    echo ========================================
    echo  INSTALLATION FAILED!
    echo ========================================
    echo.
    echo Please make sure you ran this script as Administrator.
    echo Right-click the file and select "Run as Administrator"
    echo.
)

pause
