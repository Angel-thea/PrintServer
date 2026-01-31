================================================================================
                  PRINT SERVER - PROFESSIONAL INSTALLER
================================================================================

VERSION: 1.0
UPDATED: 2026-01-30

Your Network IP: 192.168.29.209

================================================================================
RECOMMENDED INSTALLATION METHOD (NEW!)
================================================================================

Simply double-click:  INSTALL.bat

This will:
  ✓ Automatically ask for Administrator permissions
  ✓ Show you available printers to choose from
  ✓ Install to C:\Program Files\PrintServer
  ✓ Configure Windows Service (auto-start on boot)
  ✓ Configure Windows Firewall (port 9191)
  ✓ Create Start Menu shortcut
  ✓ Start the service immediately
  ✓ Test the installation

NO manual "Run as Administrator" needed - it will prompt automatically!

================================================================================
WHAT HAPPENS DURING INSTALLATION
================================================================================

1. Administrator Permission Check
   - You'll see a Windows UAC prompt
   - Click "Yes" to continue

2. Printer Selection
   - Shows list of installed printers
   - Choose your thermal printer (e.g., RP3160)
   - Or press Enter to use default (RP3160)

3. Automatic Installation
   - Copies files to Program Files
   - Installs Windows Service
   - Configures firewall
   - Creates shortcuts
   - Starts server

4. Installation Complete!
   - Server URL: http://localhost:9191
   - Network URL: http://192.168.29.209:9191

Total time: ~30 seconds

================================================================================
UNINSTALLATION
================================================================================

Option 1: Right-click Uninstall-PrintServer.ps1 → Run as Administrator

Option 2: Start Menu → Print Server → Right-click → Uninstall

Uninstaller removes:
  - All installed files
  - Windows Service
  - Firewall rules
  - Shortcuts
  - Everything!

================================================================================
ALTERNATIVE INSTALLATION METHODS
================================================================================

If you prefer manual control:

Method 1: PowerShell Installer (with options)
  Right-click PrintServerInstaller.ps1 → Run with PowerShell
  You can customize:
    - Installation path
    - Printer name
    - Firewall configuration

Method 2: Simple Auto-Start (Task Scheduler)
  Right-click INSTALL_AUTO_START.bat → Run as Administrator
  (Uses current folder, doesn't move files)

Method 3: Startup Folder
  Double-click ADD_TO_STARTUP.bat
  (Runs on user login only, shows window)

================================================================================
VERIFICATION
================================================================================

After installation, verify it's working:

1. Open browser: http://localhost:9191
   You should see: "Print Service with Logo Support is running"

2. Check status: http://localhost:9191/status
   Should show: {"online": true, ...}

3. List printers: http://localhost:9191/printers
   Should show your installed printers

4. Test print: http://localhost:9191/test-print
   Should print a test receipt

================================================================================
NETWORK ACCESS
================================================================================

From other devices on your WiFi (192.168.29.x):

  http://192.168.29.209:9191/print

The installer automatically configures Windows Firewall to allow this.

================================================================================
TROUBLESHOOTING
================================================================================

Problem: "PowerShell script not running"
Solution: Right-click INSTALL.bat → Run as administrator
          (The .bat file handles PowerShell execution policy)

Problem: "Access denied"
Solution: Make sure you click "Yes" on the UAC prompt

Problem: Printer not found after installation
Solution: Visit http://localhost:9191/printers
          Note the correct printer name
          Run uninstaller, then reinstall with correct name

Problem: Can't access from network
Solution: Check Windows Firewall is not blocking
          Both devices must be on same WiFi network

Problem: Service won't start
Solution: Check if port 9191 is already in use:
          Open PowerShell: netstat -ano | findstr :9191

================================================================================
FILES IN THIS PACKAGE
================================================================================

RECOMMENDED:
  INSTALL.bat                  - Double-click to install (EASIEST!)
  Uninstall-PrintServer.ps1    - Uninstaller

ADVANCED:
  PrintServerInstaller.ps1     - PowerShell installer (with options)
  INSTALL_AUTO_START.bat       - Simple Task Scheduler install
  ADD_TO_STARTUP.bat           - Startup folder method

APPLICATION:
  PrintServer.exe              - 41MB standalone executable
  sharp/                       - Image processing libraries

DOCUMENTATION:
  INSTALLER_README.txt         - This file
  QUICK_START_GUIDE.txt        - Quick reference
  DEPLOYMENT_GUIDE.txt         - Detailed guide

LEGACY (ignore if new methods work):
  INSTALL_SERVICE.bat          - NSSM-based (may fail to download)
  START_SERVER_MANUAL.bat      - Manual start
  CHECK_STATUS.bat             - Status checker

================================================================================
SYSTEM REQUIREMENTS
================================================================================

Operating System: Windows 7, 8, 10, 11 (64-bit)
RAM: 100MB minimum
Disk Space: 100MB
Administrator Access: Required for installation
Printer: Thermal printer with driver installed

NO Node.js required!
NO additional software required!

================================================================================
POST-INSTALLATION
================================================================================

After successful installation:

1. Server runs automatically on boot
2. Access locally: http://localhost:9191
3. Access from network: http://192.168.29.209:9191
4. Firewall is configured (port 9191)
5. Shows in Start Menu
6. Can uninstall cleanly anytime

================================================================================
DEPLOYMENT TO MULTIPLE MACHINES
================================================================================

To deploy to other Windows computers:

1. Copy entire dist folder to USB drive
2. On each machine:
   - Copy folder to any location
   - Double-click INSTALL.bat
   - Choose printer from list
   - Done!

Each machine will have its own IP address. The installer will show it.

================================================================================
SUPPORT
================================================================================

Check server status: http://localhost:9191/status
View server logs: Check console output during manual run
Test endpoints: Use /ping, /printers, /test-print

================================================================================
