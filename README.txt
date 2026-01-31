================================================================================
                  PRINT SERVER - DEVELOPER DOCUMENTATION
================================================================================

VERSION: 1.0.0
UPDATED: 2026-01-31

================================================================================
PROJECT OVERVIEW
================================================================================

Print Server is a standalone HTTP server application for network-based thermal
receipt printing with ESC/POS protocol support and logo image conversion.

Key Features:
  ✓ RESTful API for thermal printer control
  ✓ Logo URL to ESC/POS bitmap conversion
  ✓ Network printer discovery
  ✓ Auto-start and Windows service deployment options
  ✓ Standalone executable (no runtime dependencies)

Target Platform: Windows 7/8/10/11 (x64 and x86)
Printer Protocol: ESC/POS (thermal receipt printers)

================================================================================
DEVELOPMENT SETUP
================================================================================

PREREQUISITES:
  - Node.js v18 or higher
  - npm (comes with Node.js)
  - Windows OS (for testing printer functionality)
  - Thermal printer with Windows driver installed

INSTALLATION:
  1. Clone or download this repository
  2. Install dependencies:
     npm install
  3. Configure printer name in printServer.js (line 27)
  4. Start development server:
     npm start

VERIFY INSTALLATION:
  - Server starts on http://localhost:9191
  - Visit http://localhost:9191/status to check printer connection
  - Visit http://localhost:9191/printers to list available printers

================================================================================
PROJECT STRUCTURE
================================================================================

printer-server/
├── printServer.js              - Main application source code
├── package.json                - Dependencies and build scripts
├── package-lock.json           - Locked dependency versions
├── README.txt                  - This file (developer guide)
├── SYSTEM_DOCUMENTATION.md     - Complete technical documentation
├── node_modules/               - Installed npm packages
└── dist/                       - Build output directory
    ├── PrintServer.exe         - Compiled Windows executable
    ├── sharp/                  - Native image processing binaries
    ├── *.bat                   - Installation/management scripts
    ├── *.ps1                   - PowerShell installer scripts
    ├── *.txt                   - Deployment documentation
    └── nssm.zip                - Windows service manager

================================================================================
CONFIGURATION
================================================================================

Edit printServer.js to configure:

PRINTER_NAME (Line 27):
  const PRINTER_NAME = "RP3160";  // Change to your printer name

PORT (Line 24):
  const PORT = 9191;  // Change if port conflict

LOGO SETTINGS (Lines 30-32):
  const LOGO_MAX_WIDTH = 384;   // Max width in pixels
  const LOGO_MAX_HEIGHT = 150;  // Max height in pixels
  const LOGO_THRESHOLD = 128;   // Monochrome threshold (0-255)

================================================================================
DEVELOPMENT COMMANDS
================================================================================

START SERVER (Development Mode):
  npm start
  - Runs: node printServer.js
  - Hot reload: Use nodemon (install separately)

BUILD EXECUTABLE (x64):
  npm run build
  - Packages app with Node.js runtime
  - Output: dist/PrintServer.exe
  - Target: Windows x64 (64-bit)
  - Compression: GZip

BUILD EXECUTABLE (x86):
  npm run build-x86
  - Output: dist/PrintServer-x86.exe
  - Target: Windows x86 (32-bit)
  - For older or 32-bit Windows systems

================================================================================
DEPENDENCIES
================================================================================

PRODUCTION DEPENDENCIES:
  @thiagoelg/node-printer (^0.6.2)
    - Native Node.js binding for Windows printer spooler
    - Enables RAW printing to thermal printers
    - Platform-specific native module

  express (^5.2.1)
    - Web server framework
    - Handles HTTP routing and middleware
    - REST API foundation

  cors (^2.8.6)
    - Cross-Origin Resource Sharing middleware
    - Allows requests from web apps on different domains
    - Configured for all origins (*)

  sharp (^0.34.5)
    - High-performance image processing
    - Converts logos to monochrome bitmaps
    - Based on libvips (native binaries required)

DEVELOPMENT DEPENDENCIES:
  pkg (^5.8.1)
    - Packages Node.js app into executable
    - Bundles Node.js runtime and dependencies
    - Supports Windows, Linux, macOS

================================================================================
API ENDPOINTS
================================================================================

HEALTH & DISCOVERY:
  GET  /              - Health check ("Print Service... is running")
  GET  /ping          - Discovery endpoint (returns server info)
  GET  /status        - Printer availability check
  GET  /printers      - List all installed printers

PRINTING OPERATIONS:
  POST /print         - Print ESC/POS data to thermal printer
  POST /convert-logo  - Convert logo URL to ESC/POS bitmap
  GET  /test-print    - Send test print to verify printer

See SYSTEM_DOCUMENTATION.md for detailed API specifications.

================================================================================
BUILD PROCESS
================================================================================

The build process uses 'pkg' to create standalone executables:

1. BUNDLING:
   - Compiles Node.js source code
   - Embeds Node.js v18 runtime
   - Includes specified assets (sharp, node-printer)

2. ASSETS INCLUDED (package.json):
   - node_modules/@thiagoelg/node-printer/**/*
   - node_modules/sharp/**/*

3. OUTPUT:
   - Single .exe file (42MB)
   - sharp/ folder (native binaries)
   - Must be deployed together

4. COMPRESSION:
   - GZip compression applied
   - Reduces executable size
   - No impact on runtime performance

IMPORTANT: The sharp/ folder MUST be in the same directory as the .exe
           file. It contains native image processing libraries required
           at runtime. Without it, logo conversion will fail.

================================================================================
TESTING
================================================================================

MANUAL TESTING:

1. Start server: npm start

2. Health check:
   http://localhost:9191/

3. Check printer status:
   http://localhost:9191/status

4. List printers:
   http://localhost:9191/printers

5. Test print:
   http://localhost:9191/test-print

6. Test logo conversion:
   curl -X POST http://localhost:9191/convert-logo \
     -H "Content-Type: application/json" \
     -d "{\"logoUrl\":\"https://example.com/logo.png\"}"

7. Test printing:
   curl -X POST http://localhost:9191/print \
     -H "Content-Type: application/json" \
     -d "{\"escpos\":\"base64_data\",\"encoding\":\"base64\"}"

NETWORK TESTING:
   - Find server IP: Check console output on startup
   - From another device: http://[SERVER-IP]:9191/status
   - Ensure Windows Firewall allows port 9191

================================================================================
DEPLOYMENT
================================================================================

BUILDING FOR DEPLOYMENT:

1. Configure printer name in printServer.js
2. Run: npm run build
3. Copy entire dist/ folder to target machine
4. User runs INSTALL.bat or other installation method

DEPLOYMENT METHODS (User Chooses):
  - Manual start: START_SERVER_MANUAL.bat
  - Auto-start on login: INSTALL_AUTO_START.bat
  - Windows service: INSTALL_SERVICE.bat (requires admin)
  - PowerShell installer: PrintServerInstaller.ps1 (requires admin)

See dist/README.txt for end-user deployment instructions.

================================================================================
TROUBLESHOOTING DEVELOPMENT
================================================================================

Problem: npm install fails for sharp
Solution: Ensure compatible Node.js version (v18+)
          On Windows, may need Visual C++ Build Tools

Problem: npm install fails for node-printer
Solution: Native module requires node-gyp and build tools
          Install: npm install --global windows-build-tools

Problem: Can't find printer when testing
Solution: 1. Check printer is installed with Windows driver
          2. Verify printer name at /printers endpoint
          3. Update PRINTER_NAME in printServer.js

Problem: Build fails with pkg
Solution: 1. Ensure pkg is installed: npm install
          2. Check Node.js version compatibility
          3. Verify package.json assets paths are correct

Problem: Logo conversion fails in development
Solution: 1. Check sharp installation: npm list sharp
          2. Reinstall: npm uninstall sharp && npm install sharp
          3. Ensure internet connection for downloading test logos

================================================================================
CODE STRUCTURE
================================================================================

printServer.js SECTIONS:

Lines 1-22:    Imports and setup
Lines 23-28:   Configuration constants
Lines 29-35:   Express middleware setup
Lines 36-51:   Network utility functions
Lines 52-86:   Health and discovery endpoints
Lines 87-107:  Image download function
Lines 108-194: Image to ESC/POS conversion (core algorithm)
Lines 195-243: Logo conversion endpoint
Lines 244-298: Print endpoint
Lines 299-319: Test print endpoint
Lines 320-329: Printer listing endpoint
Lines 330-350: Server startup and console output

CORE ALGORITHM (imageToEscPosBitmap):
  1. Load image with Sharp
  2. Resize maintaining aspect ratio (max 384x150px)
  3. Convert to grayscale
  4. Apply monochrome threshold (128)
  5. Pack pixels into bytes (8 pixels per byte)
  6. Generate ESC/POS GS v 0 command
  7. Add alignment and formatting commands

================================================================================
SECURITY CONSIDERATIONS
================================================================================

CURRENT IMPLEMENTATION:
  ⚠ No authentication or API keys
  ⚠ No HTTPS/TLS encryption
  ⚠ CORS allows all origins
  ⚠ No rate limiting
  ⚠ No input sanitization beyond basic validation

RECOMMENDED FOR PRODUCTION:
  - Deploy on isolated internal network
  - Use firewall to restrict access
  - Add authentication layer (API keys, OAuth)
  - Implement HTTPS with valid certificates
  - Add rate limiting middleware
  - Validate and sanitize all inputs
  - Log all print jobs for audit trail

USE CASES:
  ✓ Internal network printer service
  ✓ Point-of-sale systems on local network
  ✓ Receipt printing for web apps (same network)
  ✗ Public internet exposure (not recommended without security)

================================================================================
PERFORMANCE NOTES
================================================================================

Logo Conversion:
  - Average time: 500-2000ms (varies by image size and complexity)
  - Memory spike: ~50-100MB during processing
  - Bottleneck: Image download (depends on network speed)
  - Optimization: Client-side caching of converted logos

Print Operations:
  - Submission time: <100ms
  - Network latency: 50-200ms (local network)
  - Actual print speed: Hardware-dependent (thermal printer)
  - Queue: Handled by Windows print spooler

Concurrent Requests:
  - Express.js handles async requests efficiently
  - No request queuing implemented in app
  - Printer queue managed by Windows spooler
  - Recommend: 10-20 concurrent requests max

================================================================================
ESC/POS PROTOCOL REFERENCE
================================================================================

COMMANDS USED IN THIS PROJECT:

Initialize Printer:
  ESC @ (0x1B 0x40)

Text Alignment:
  ESC a n (0x1B 0x61 n)
  - n=0: Left align
  - n=1: Center
  - n=2: Right align

Print Raster Bitmap:
  GS v 0 m xL xH yL yH [data] (0x1D 0x76 0x30 m xL xH yL yH)
  - m: Mode (0=normal, 1=double width, 2=double height, 3=quad)
  - xL, xH: Width in bytes (little-endian)
  - yL, yH: Height in pixels (little-endian)
  - data: Bitmap data (1 bit per pixel, 8 pixels per byte)

Line Feed:
  LF (0x0A)

Paper Cut:
  GS V 1 (0x1D 0x56 0x01) - Full cut
  GS V 0 (0x1D 0x56 0x00) - Partial cut

================================================================================
FUTURE ENHANCEMENTS
================================================================================

Potential features for future versions:

  - HTTPS/SSL support
  - Authentication & API keys
  - Print job queue management
  - WebSocket support for real-time status
  - Multi-printer support (dynamic selection)
  - Print job history and logging
  - Web-based admin panel
  - PDF to ESC/POS conversion
  - Template-based receipt generation
  - QR code and barcode generation
  - Email/webhook notifications for print jobs
  - Remote printer management dashboard

================================================================================
VERSION HISTORY
================================================================================

Version 1.0.0 (2026-01-30):
  - Initial release
  - Core printing functionality
  - Logo conversion support
  - Multiple installation methods
  - Comprehensive documentation

================================================================================
LICENSE & CREDITS
================================================================================

Dependencies are licensed under their respective licenses:
  - Express.js: MIT License
  - Sharp: Apache 2.0 License
  - node-printer: MIT License
  - CORS: MIT License
  - pkg: MIT License

================================================================================
SUPPORT & CONTRIBUTION
================================================================================

For development questions:
  1. Check SYSTEM_DOCUMENTATION.md for architecture details
  2. Review code comments in printServer.js
  3. Test endpoints using browser or curl
  4. Check console logs for detailed error messages

When reporting issues:
  - Include Node.js version (node --version)
  - Include npm version (npm --version)
  - Include Windows version
  - Include printer model and driver version
  - Provide console error logs
  - Describe reproduction steps

================================================================================
