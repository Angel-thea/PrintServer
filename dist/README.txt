================================================================================
              PRINT SERVER - DEPLOYMENT INSTRUCTIONS
================================================================================

VERSION: 1.0.0
CREATED: 2026-01-30
UPDATED: 2026-01-31

================================================================================
WHAT'S INCLUDED
================================================================================

EXECUTABLES:
  PrintServer.exe              - Main application (Node.js v18 bundled inside)
  sharp/                       - Native image processing libraries (REQUIRED)

INSTALLATION SCRIPTS:
  INSTALL.bat                  - Quick installer (recommended for first-time)
  INSTALL_AUTO_START.bat       - Install auto-start on user login
  INSTALL_SERVICE.bat          - Install as Windows service (requires admin)
  PrintServerInstaller.ps1     - PowerShell automated installer

MANAGEMENT SCRIPTS:
  START_SERVER_MANUAL.bat      - Start server manually (console mode)
  CHECK_STATUS.bat             - Check if server is running
  SERVICE_STATUS.bat           - Check Windows service status
  ADD_TO_STARTUP.bat           - Add to Windows startup folder

UNINSTALL SCRIPTS:
  UNINSTALL_AUTO_START.bat     - Remove auto-start configuration
  UNINSTALL_SERVICE.bat        - Remove Windows service
  Uninstall-PrintServer.ps1    - PowerShell automated uninstaller

DOCUMENTATION:
  README.txt                   - This file (quick reference)
  DEPLOYMENT_GUIDE.txt         - Detailed deployment instructions
  INSTALLER_README.txt         - Installer script documentation
  QUICK_START_GUIDE.txt        - Quick start reference guide

UTILITIES:
  nssm.zip                     - NSSM (Non-Sucking Service Manager)

================================================================================
SYSTEM REQUIREMENTS
================================================================================

✅ Windows 7, 8, 10, 11 (64-bit)
✅ Thermal printer installed with driver (e.g., RP3160)
✅ Network connection (if accessing from other devices)

❌ NO Node.js required
❌ NO npm required
❌ NO additional software needed

================================================================================
QUICK START (RECOMMENDED)
================================================================================

1. COPY THE ENTIRE FOLDER
   - Copy the whole 'dist' folder to the target machine
   - DO NOT just copy PrintServer.exe alone
   - The 'sharp' folder MUST be in the same directory as PrintServer.exe

2. RUN THE INSTALLER
   - Double-click INSTALL.bat
   - Follow the on-screen prompts
   - The installer will guide you through setup

3. VERIFY IT'S RUNNING
   - Open browser: http://localhost:9191
   - Should show: "Print Service with Logo Support is running"
   - Check printer status: http://localhost:9191/status

4. ALLOW FIREWALL (if prompted)
   - Windows may ask to allow network access
   - Click "Allow" to enable network printing

================================================================================
INSTALLATION METHODS (CHOOSE ONE)
================================================================================

METHOD 1: MANUAL START (Simplest)
  - Run: START_SERVER_MANUAL.bat
  - Server runs in console window
  - Stops when console is closed
  - Best for: Testing, temporary use

METHOD 2: AUTO-START ON LOGIN
  - Run: INSTALL_AUTO_START.bat
  - Server starts automatically when user logs in
  - Runs in background
  - Best for: Single-user workstations
  - Uninstall: UNINSTALL_AUTO_START.bat

METHOD 3: WINDOWS SERVICE (Recommended for Production)
  - Run: INSTALL_SERVICE.bat (as Administrator)
  - Server runs as Windows service
  - Starts automatically on system boot
  - Runs even when no user logged in
  - Best for: Production, multi-user systems, servers
  - Uninstall: UNINSTALL_SERVICE.bat (as Administrator)

METHOD 4: POWERSHELL AUTOMATED INSTALLER
  - Run: PrintServerInstaller.ps1 (as Administrator)
  - Fully automated installation with service setup
  - Best for: Enterprise deployment, scripted installations
  - Uninstall: Uninstall-PrintServer.ps1 (as Administrator)

================================================================================
CONFIGURE PRINTER NAME (IF NEEDED)
================================================================================

Default printer: RP3160

To check your printer name:
  1. Visit: http://localhost:9191/printers
  2. Find your thermal printer in the list
  3. If it matches "RP3160", no changes needed!

To change printer name:
  1. Edit printServer.js (source): Line 27: const PRINTER_NAME = "YOUR_PRINTER";
  2. Rebuild: npm run build
  3. Redeploy the dist folder

================================================================================
NETWORK ACCESS
================================================================================

To print from other devices on the network:

1. Find the server's IP address (shown in console when server starts)
2. On client device, use: http://[SERVER-IP]:9191/print
3. Make sure Windows Firewall allows port 9191

Example: http://192.168.1.100:9191

================================================================================
AVAILABLE ENDPOINTS
================================================================================

GET  /                  - Health check
GET  /ping              - Discovery endpoint
GET  /status            - Printer status
GET  /printers          - List all installed printers
GET  /test-print        - Send test print
POST /convert-logo      - Convert logo URL to ESC/POS
POST /print             - Print ESC/POS data

================================================================================
MANAGEMENT & MONITORING
================================================================================

CHECK SERVER STATUS:
  - Run: CHECK_STATUS.bat
  - Opens status page in browser
  - Shows: Server online, printer status, capabilities

CHECK SERVICE STATUS (if installed as service):
  - Run: SERVICE_STATUS.bat
  - Shows Windows service status

STOP THE SERVER:
  - Manual mode: Close console window OR press Ctrl+C
  - Auto-start: Kill process from Task Manager
  - Service mode: Run UNINSTALL_SERVICE.bat OR use Services.msc

RESTART THE SERVER:
  - Manual mode: Close and reopen START_SERVER_MANUAL.bat
  - Auto-start: Log out and log back in
  - Service mode: Services.msc → Print Server → Restart

================================================================================
TROUBLESHOOTING
================================================================================

Problem: "Cannot find module 'sharp'"
Solution: Make sure the 'sharp' folder is in the same directory as the .exe
          Never move PrintServer.exe alone - always move entire folder

Problem: "Printer not found"
Solution: 1. Visit http://localhost:9191/printers
          2. Verify your thermal printer is listed
          3. Check printer is online and has driver installed
          4. If name doesn't match "RP3160", rebuild with correct name

Problem: Can't access from network
Solution: 1. Check Windows Firewall settings for port 9191
          2. Run: netsh advfirewall firewall show rule name="Print Server"
          3. Add rule: netsh advfirewall firewall add rule name="Print Server"
             dir=in action=allow protocol=TCP localport=9191

Problem: Logo conversion fails
Solution: 1. Ensure server can access the internet to download logos
          2. Check logo URL is accessible from server
          3. Verify proxy settings if behind corporate firewall

Problem: Server won't start on port 9191
Solution: 1. Check if port is already in use
          2. Run: netstat -ano | findstr :9191
          3. Close other instances or change port in source code

Problem: Service won't start
Solution: 1. Run SERVICE_STATUS.bat to check status
          2. Check Windows Event Viewer for errors
          3. Verify NSSM is properly configured
          4. Reinstall: UNINSTALL_SERVICE.bat then INSTALL_SERVICE.bat

Problem: Prints are garbled or wrong format
Solution: 1. Verify printer supports ESC/POS protocol
          2. Check printer driver is correctly installed
          3. Test with /test-print endpoint
          4. Ensure ESC/POS data is properly base64-encoded

================================================================================
API USAGE EXAMPLES
================================================================================

CHECK SERVER STATUS (Browser or cURL):
  http://localhost:9191/status

PRINT FROM JAVASCRIPT:
  fetch('http://localhost:9191/print', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      escpos: 'base64_encoded_escpos_data',
      printerName: 'RP3160',
      encoding: 'base64'
    })
  });

CONVERT LOGO (ONE-TIME, CLIENT CACHES RESULT):
  fetch('http://localhost:9191/convert-logo', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      logoUrl: 'https://example.com/logo.png'
    })
  });

PRINT FROM CURL:
  curl -X POST http://localhost:9191/print ^
    -H "Content-Type: application/json" ^
    -d "{\"escpos\":\"base64_data\",\"printerName\":\"RP3160\",\"encoding\":\"base64\"}"

================================================================================
TECHNICAL DETAILS
================================================================================

Application:
  Name: Print Server with Logo Support
  Version: 1.0.0
  Port: 9191
  Protocol: HTTP (no authentication, CORS enabled)
  Binding: 0.0.0.0 (all network interfaces)

Platform:
  Architecture: x64 (64-bit Windows)
  OS Support: Windows 7, 8, 10, 11
  Node.js: v18 (bundled, no installation required)

Dependencies (bundled):
  - Express.js v5.2.1 (Web server framework)
  - Sharp v0.34.5 (Image processing)
  - node-printer v0.6.2 (Printer interface)
  - CORS v2.8.6 (Cross-origin support)

Logo Processing:
  Max Width: 384 pixels (80mm thermal printers)
  Max Height: 150 pixels
  Threshold: 128 (0-255 brightness scale)
  Supported Formats: PNG, JPG, GIF, WebP, TIFF, SVG

Printer Protocol:
  Type: ESC/POS (thermal receipt printers)
  Mode: RAW print data to Windows print spooler
  Alignment: Center (logos), Left (text)
  Commands: ESC/POS bitmap (GS v 0), text formatting, paper cut

Performance:
  Logo conversion: 500-2000ms (varies by image size)
  Print submission: <100ms
  Memory usage: ~50-100MB during image processing
  Concurrent requests: Supported (async handling)

Security Notes:
  ⚠ No authentication - Open HTTP endpoints
  ⚠ No encryption - Plain HTTP (not HTTPS)
  ⚠ CORS enabled for all origins
  Recommended: Use on isolated internal network or behind firewall

================================================================================
ADDITIONAL DOCUMENTATION
================================================================================

For detailed technical documentation, see:
  - DEPLOYMENT_GUIDE.txt    - Comprehensive deployment instructions
  - INSTALLER_README.txt    - Installation script documentation
  - QUICK_START_GUIDE.txt   - Quick reference guide
  - SYSTEM_DOCUMENTATION.md - Full system architecture (in source folder)

================================================================================
SUPPORT & LOGS
================================================================================

Server Logs:
  - Console output shows all requests and operations
  - Logo conversion progress with size/dimensions
  - Print job IDs and success/failure status
  - Error messages with details

For issues or questions:
  1. Check the console window for error messages
  2. Visit http://localhost:9191/status for server health
  3. Review the troubleshooting section above
  4. Check firewall and printer driver settings

================================================================================
