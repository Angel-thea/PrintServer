# Print Server - Automated Portable Bundle Builder
# This script downloads Node.js portable and creates a standalone package

param(
    [string]$NodeVersion = "20.11.0",
    [string]$OutputDir = "PrintServer-Portable",
    [switch]$SkipNodeDownload = $false
)

$ErrorActionPreference = "Stop"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Print Server - Portable Bundle Builder" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Configuration
$NodeURL = "https://nodejs.org/dist/v$NodeVersion/node-v$NodeVersion-win-x64.zip"
$NodeZip = "node-portable.zip"
$ScriptDir = $PSScriptRoot

# Step 1: Clean output directory
Write-Host "[1/7] Preparing output directory..." -ForegroundColor Yellow
if (Test-Path $OutputDir) {
    Remove-Item $OutputDir -Recurse -Force
}
New-Item -ItemType Directory -Path $OutputDir | Out-Null
Write-Host "[OK] Output directory ready`n" -ForegroundColor Green

# Step 2: Copy application files
Write-Host "[2/7] Copying application files..." -ForegroundColor Yellow
Copy-Item "$ScriptDir\printServer.js" -Destination $OutputDir
Copy-Item "$ScriptDir\package.json" -Destination $OutputDir
Copy-Item "$ScriptDir\Start-PrintServer.bat" -Destination $OutputDir
Copy-Item "$ScriptDir\Stop-PrintServer.bat" -Destination $OutputDir

if (Test-Path "$ScriptDir\node_modules") {
    Copy-Item "$ScriptDir\node_modules" -Destination "$OutputDir\node_modules" -Recurse
    Write-Host "[OK] Application files copied (including node_modules)`n" -ForegroundColor Green
} else {
    Write-Host "[WARNING] node_modules not found. You need to run 'npm install' first!`n" -ForegroundColor Red
    Write-Host "Run this command in the project directory:" -ForegroundColor Yellow
    Write-Host "  npm install`n" -ForegroundColor White
    exit 1
}

# Step 3: Download Node.js portable
if (-not $SkipNodeDownload) {
    Write-Host "[3/7] Downloading Node.js portable v$NodeVersion..." -ForegroundColor Yellow
    Write-Host "      URL: $NodeURL" -ForegroundColor Gray

    try {
        Invoke-WebRequest -Uri $NodeURL -OutFile $NodeZip -UseBasicParsing
        Write-Host "[OK] Node.js downloaded`n" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Failed to download Node.js: $($_.Exception.Message)`n" -ForegroundColor Red
        exit 1
    }

    # Step 4: Extract Node.js
    Write-Host "[4/7] Extracting Node.js..." -ForegroundColor Yellow
    Expand-Archive -Path $NodeZip -DestinationPath "temp-node" -Force

    # Move to nodejs folder
    $ExtractedFolder = Get-ChildItem "temp-node" | Select-Object -First 1
    Move-Item "temp-node\$($ExtractedFolder.Name)" "$OutputDir\nodejs" -Force

    # Cleanup
    Remove-Item "temp-node" -Recurse -Force
    Remove-Item $NodeZip -Force

    Write-Host "[OK] Node.js extracted`n" -ForegroundColor Green
} else {
    Write-Host "[3/7] Skipping Node.js download (manual mode)`n" -ForegroundColor Yellow
    Write-Host "[4/7] Skipping Node.js extraction`n" -ForegroundColor Yellow
}

# Step 5: Create README
Write-Host "[5/7] Creating documentation..." -ForegroundColor Yellow
$ReadmeContent = @"
================================================================================
                   PRINT SERVER - PORTABLE VERSION
================================================================================

VERSION: 1.0.0
CREATED: $(Get-Date -Format "yyyy-MM-dd")

This is a portable version that runs on any Windows PC without installation.

================================================================================
SYSTEM REQUIREMENTS
================================================================================

✅ Windows 7, 8, 10, or 11 (64-bit)
✅ Thermal printer with driver installed (e.g., RP3160)
✅ Network connection (optional, for remote printing)

❌ NO Node.js required
❌ NO npm required
❌ NO installation required

================================================================================
QUICK START
================================================================================

1. Copy this entire folder to any location on your PC
2. Double-click: Start-PrintServer.bat
3. Browser opens to: http://localhost:9191
4. Done! Server is running

================================================================================
HOW TO USE
================================================================================

START SERVER:
  Double-click: Start-PrintServer.bat
  - Server starts in background
  - Browser opens automatically
  - Server URL: http://localhost:9191

STOP SERVER:
  Double-click: Stop-PrintServer.bat
  - Stops the server gracefully

CHECK STATUS:
  Open browser: http://localhost:9191/status
  Shows printer status and server information

================================================================================
NETWORK PRINTING
================================================================================

To print from other devices (phones, tablets, other PCs):

1. Find your PC's IP address:
   - Open Command Prompt
   - Type: ipconfig
   - Look for IPv4 Address (e.g., 192.168.1.100)

2. On other devices, use:
   http://[YOUR-PC-IP]:9191/print

3. Allow firewall when prompted:
   - Windows will ask to allow network access
   - Click "Allow access"

Example: http://192.168.1.100:9191

================================================================================
PRINTER CONFIGURATION
================================================================================

Default printer: RP3160

To check your printer name:
  1. Start the server
  2. Visit: http://localhost:9191/printers
  3. Find your thermal printer in the list

To change printer name:
  1. Edit: printServer.js
  2. Line 27: const PRINTER_NAME = "YOUR_PRINTER_NAME";
  3. Save and restart server

================================================================================
API ENDPOINTS
================================================================================

GET  /                  - Health check
GET  /ping              - Discovery endpoint
GET  /status            - Printer status
GET  /printers          - List all installed printers
GET  /test-print        - Send test print
POST /print             - Print ESC/POS data
POST /convert-logo      - Convert logo URL to ESC/POS

Full API documentation available at:
  http://localhost:9191/status

================================================================================
DEPLOYMENT TO OTHER COMPUTERS
================================================================================

Simply copy this entire folder to:
  - USB drive
  - Network share
  - Other computer

No installation needed! Just run Start-PrintServer.bat

Recommended location on target PC:
  C:\PrintServer

================================================================================
AUTO-START ON WINDOWS STARTUP
================================================================================

To make the server start automatically:

1. Press Win+R
2. Type: shell:startup
3. Create shortcut to: Start-PrintServer.bat
4. Done! Server starts when Windows starts

================================================================================
TROUBLESHOOTING
================================================================================

Problem: "Node.js not found"
Solution: Ensure the 'nodejs' folder is in the same directory

Problem: "Cannot find module"
Solution: Ensure 'node_modules' folder is present

Problem: "Printer not found"
Solution: 1. Check printer driver is installed
          2. Visit /printers to see available printers
          3. Update printer name in printServer.js

Problem: Can't access from network
Solution: 1. Allow port 9191 in Windows Firewall
          2. Check PC's IP address is correct

Problem: Server won't start
Solution: 1. Check if port 9191 is already in use
          2. Run Stop-PrintServer.bat first
          3. Try again

================================================================================
FOLDER STRUCTURE
================================================================================

PrintServer-Portable/
├── nodejs/              - Node.js runtime (portable)
├── node_modules/        - Application dependencies
├── printServer.js       - Main application code
├── package.json         - Application metadata
├── Start-PrintServer.bat - Start script
├── Stop-PrintServer.bat  - Stop script
└── README.txt           - This file

Total Size: ~100MB

================================================================================
SUPPORT
================================================================================

For issues or questions:
  1. Check server console for errors
  2. Visit: http://localhost:9191/status
  3. Review this README for troubleshooting

================================================================================
"@

Set-Content -Path "$OutputDir\README.txt" -Value $ReadmeContent -Encoding UTF8
Write-Host "[OK] Documentation created`n" -ForegroundColor Green

# Step 6: Create launcher icon (optional)
Write-Host "[6/7] Finalizing bundle..." -ForegroundColor Yellow
# Additional configurations can go here
Write-Host "[OK] Bundle finalized`n" -ForegroundColor Green

# Step 7: Summary
Write-Host "[7/7] Build complete!`n" -ForegroundColor Yellow

$BundleSize = (Get-ChildItem $OutputDir -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  BUILD SUCCESSFUL!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Output Location:" -ForegroundColor Yellow
Write-Host "  $OutputDir`n" -ForegroundColor White

Write-Host "Bundle Size:" -ForegroundColor Yellow
Write-Host "  $([math]::Round($BundleSize, 2)) MB`n" -ForegroundColor White

Write-Host "Contents:" -ForegroundColor Yellow
Write-Host "  ✓ Node.js v$NodeVersion (portable)" -ForegroundColor White
Write-Host "  ✓ Print Server application" -ForegroundColor White
Write-Host "  ✓ All dependencies (node_modules)" -ForegroundColor White
Write-Host "  ✓ Launcher scripts" -ForegroundColor White
Write-Host "  ✓ Documentation`n" -ForegroundColor White

Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Test the bundle:" -ForegroundColor White
Write-Host "     cd $OutputDir" -ForegroundColor Gray
Write-Host "     .\Start-PrintServer.bat`n" -ForegroundColor Gray

Write-Host "  2. Deploy to other computers:" -ForegroundColor White
Write-Host "     - Copy entire '$OutputDir' folder" -ForegroundColor Gray
Write-Host "     - Run Start-PrintServer.bat on target PC`n" -ForegroundColor Gray

Write-Host "  3. Create installer (optional):" -ForegroundColor White
Write-Host "     - Use Inno Setup with installer-script.iss" -ForegroundColor Gray
Write-Host "     - Or ZIP the folder for easy distribution`n" -ForegroundColor Gray

Write-Host "========================================`n" -ForegroundColor Cyan
