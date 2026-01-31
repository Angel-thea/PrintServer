================================================================================
                   PRINT SERVER - PORTABLE VERSION
================================================================================

VERSION: 1.0.0
BUILD DATE: 2026-01-31

This is a PORTABLE version that runs on ANY Windows PC WITHOUT installation!

NO Node.js required!
NO npm required!
NO installation required!

================================================================================
QUICK START
================================================================================

1. Copy this entire folder to your computer
2. Double-click: Start-PrintServer.bat
3. Browser opens to: http://localhost:9191
4. Done!

================================================================================
SYSTEM REQUIREMENTS
================================================================================

- Windows 7, 8, 10, or 11 (64-bit)
- Thermal printer with driver installed (e.g., RP3160)
- Network connection (optional, for remote printing)

================================================================================
HOW TO USE
================================================================================

START SERVER:
  Double-click: Start-PrintServer.bat
  - Server starts in background
  - Browser opens automatically

STOP SERVER:
  Double-click: Stop-PrintServer.bat

CHECK STATUS:
  Open: http://localhost:9191/status

TEST PRINT:
  Open: http://localhost:9191/test-print

================================================================================
DEPLOYMENT TO OTHER COMPUTERS
================================================================================

Simply copy this ENTIRE folder to:
  - USB drive
  - Network share
  - Another computer

Then run Start-PrintServer.bat on the target computer.

THAT'S IT! No installation needed!

================================================================================
NETWORK PRINTING
================================================================================

To print from other devices (phones, tablets, other PCs):

1. Find your PC's IP address (shown when server starts)
2. On other devices, use: http://[YOUR-PC-IP]:9191/print
3. Allow Windows Firewall when prompted

Example: http://192.168.29.209:9191

================================================================================
PRINTER CONFIGURATION
================================================================================

Default printer: RP3160

To change:
  1. Edit: printServer.js
  2. Line 27: const PRINTER_NAME = "YOUR_PRINTER";
  3. Save and restart server

To check available printers:
  http://localhost:9191/printers

================================================================================
API ENDPOINTS
================================================================================

GET  /               - Health check
GET  /ping           - Discovery
GET  /status         - Printer status
GET  /printers       - List printers
GET  /test-print     - Test print
POST /print          - Print ESC/POS data
POST /convert-logo   - Convert logo to ESC/POS

================================================================================
AUTO-START ON WINDOWS STARTUP
================================================================================

Print Server does NOT start automatically by default.

THREE OPTIONS TO MAKE IT AUTO-START:

OPTION 1: AUTO-START ON LOGIN (Easiest)
  - Double-click: INSTALL_AUTO_START.bat
  - Server starts when you log in
  - Runs in background (no console window)
  - To remove: UNINSTALL_AUTO_START.bat

OPTION 2: WINDOWS SERVICE (Most Reliable)
  - Right-click: INSTALL_WINDOWS_SERVICE.bat → Run as Administrator
  - Server starts when Windows boots (before login)
  - Best for servers and 24/7 operation
  - To remove: UNINSTALL_WINDOWS_SERVICE.bat (as Administrator)

OPTION 3: MANUAL (Default)
  - Start: Double-click Start-PrintServer.bat
  - Stop: Double-click Stop-PrintServer.bat
  - You control when it runs

See AUTO_START_GUIDE.txt for detailed instructions

================================================================================
FOLDER CONTENTS
================================================================================

PrintServer-Portable/
├── nodejs/             - Node.js runtime (portable)
├── node_modules/       - Application dependencies
├── printServer.js      - Main application
├── package.json        - App metadata
├── Start-PrintServer.bat - Start script
├── Stop-PrintServer.bat  - Stop script
└── README.txt          - This file

Total Size: ~135 MB

================================================================================
TROUBLESHOOTING
================================================================================

Problem: Server won't start
Solution: 1. Run Stop-PrintServer.bat first
          2. Try Start-PrintServer.bat again
          3. Check if port 9191 is available

Problem: Printer not found
Solution: 1. Check printer driver is installed
          2. Visit /printers to see available printers
          3. Update printer name in printServer.js

Problem: Can't access from network
Solution: Allow port 9191 in Windows Firewall

================================================================================
SUPPORT
================================================================================

For help:
  - Check http://localhost:9191/status
  - Review server console for errors
  - See troubleshooting section above

================================================================================
