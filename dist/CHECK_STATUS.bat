@echo off
echo ========================================
echo  PRINT SERVER - STATUS CHECK
echo ========================================
echo.

echo [1] Checking scheduled task...
schtasks /Query /TN "PrintServer" /FO LIST 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Task not found - Print Server is NOT configured for auto-start
) else (
    echo Task found - Print Server is configured for auto-start
)

echo.
echo [2] Checking if server is running...
tasklist /FI "IMAGENAME eq PrintServer.exe" 2>NUL | find /I /N "PrintServer.exe" >NUL
if "%ERRORLEVEL%"=="0" (
    echo Process Status: RUNNING
) else (
    echo Process Status: NOT RUNNING
)

echo.
echo [3] Testing HTTP endpoint...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:9191' -UseBasicParsing -TimeoutSec 2; Write-Host 'HTTP Status: ONLINE' -ForegroundColor Green; Write-Host 'Response:' $response.Content } catch { Write-Host 'HTTP Status: OFFLINE or NOT RESPONDING' -ForegroundColor Red }"

echo.
echo [4] Your Network IP Addresses:
echo    Local: http://localhost:9191
echo    WiFi:  http://192.168.29.209:9191
echo.
echo ========================================
pause
