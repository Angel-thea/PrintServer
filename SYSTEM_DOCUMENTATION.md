# Print Server System Documentation

## System Overview

**Print Server** is a standalone HTTP server application that enables network-based thermal receipt printing with ESC/POS protocol support and logo image conversion capabilities. The system is designed to run on Windows machines and allows remote printing from web applications or mobile apps.

### Version Information
- **Version:** 1.0.0
- **Platform:** Windows (x64/x86)
- **Node.js Version:** 18 (bundled in executable)
- **Server Port:** 9191
- **Protocol:** HTTP

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                  Client Applications                     │
│         (Web Apps, Mobile Apps, POS Systems)            │
└────────────────────┬────────────────────────────────────┘
                     │ HTTP Requests (Port 9191)
                     │
┌────────────────────▼────────────────────────────────────┐
│              Print Server (Express.js)                   │
│  ┌───────────────────────────────────────────────────┐  │
│  │  API Endpoints                                     │  │
│  │  - /ping          - Server discovery              │  │
│  │  - /status        - Printer status check          │  │
│  │  - /print         - Print ESC/POS data            │  │
│  │  - /convert-logo  - Logo to ESC/POS conversion    │  │
│  │  - /printers      - List available printers       │  │
│  │  - /test-print    - Send test print               │  │
│  └───────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Core Modules                                      │  │
│  │  - Image Processing (Sharp)                        │  │
│  │  - HTTP Client (HTTPS/HTTP)                        │  │
│  │  - Network Discovery (OS interfaces)               │  │
│  └───────────────────────────────────────────────────┘  │
└────────────────────┬────────────────────────────────────┘
                     │ RAW Print Commands
                     │
┌────────────────────▼────────────────────────────────────┐
│          node-printer (Native Binding)                   │
│         Interfaces with Windows Print Spooler            │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│              Thermal Printer (RP3160)                    │
│                  ESC/POS Compatible                      │
└─────────────────────────────────────────────────────────┘
```

---

## Core Components

### 1. Main Application (`printServer.js`)

**Purpose:** Express.js HTTP server that handles print requests and logo conversion

**Key Features:**
- RESTful API for print operations
- ESC/POS command processing
- Logo image conversion to thermal printer format
- Network printer discovery
- CORS support for cross-origin requests

**Configuration Constants:**
```javascript
PORT = 9191                    // Server listening port
PRINTER_NAME = "RP3160"        // Target thermal printer name
LOGO_MAX_WIDTH = 384           // Max logo width (pixels)
LOGO_MAX_HEIGHT = 150          // Max logo height (pixels)
LOGO_THRESHOLD = 128           // Monochrome brightness threshold (0-255)
```

### 2. Dependencies

#### Production Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `@thiagoelg/node-printer` | ^0.6.2 | Native Node.js printer binding for Windows |
| `express` | ^5.2.1 | HTTP server framework |
| `cors` | ^2.8.6 | Cross-Origin Resource Sharing middleware |
| `sharp` | ^0.34.5 | High-performance image processing library |

#### Development Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `pkg` | ^5.8.1 | Package Node.js app into executable |

---

## API Endpoints

### Health & Discovery

#### `GET /`
**Purpose:** Basic health check

**Response:**
```
"Print Service with Logo Support is running"
```

#### `GET /ping`
**Purpose:** Server discovery for client applications

**Response:**
```json
{
  "status": "online",
  "name": "Print Server",
  "printerModel": "RP3160",
  "printer": "RP3160",
  "logoSupport": true
}
```

#### `GET /status`
**Purpose:** Check printer availability and server status

**Response:**
```json
{
  "online": true,
  "name": "Print Server",
  "printerModel": "RP3160",
  "printerName": "RP3160",
  "available": true,
  "logoSupport": true
}
```

#### `GET /printers`
**Purpose:** List all installed printers on the system

**Response:**
```json
{
  "printers": [
    { "name": "RP3160", /* ... printer details ... */ }
  ]
}
```

---

### Printing Operations

#### `POST /print`
**Purpose:** Print ESC/POS commands to the configured printer

**Request Body:**
```json
{
  "escpos": "base64_encoded_escpos_data",
  "printerName": "RP3160",
  "encoding": "base64"
}
```

**Response (Success):**
```json
{
  "success": true,
  "jobID": "12345"
}
```

**Response (Error):**
```json
{
  "error": "Printer not found"
}
```

**Process Flow:**
1. Receive base64-encoded ESC/POS data
2. Decode to binary buffer
3. Send to Windows printer spooler as RAW data
4. Return job ID on success

#### `POST /convert-logo`
**Purpose:** Convert logo image URL to ESC/POS bitmap format (one-time conversion, client caches result)

**Request Body:**
```json
{
  "logoUrl": "https://example.com/logo.png"
}
```

**Response (Success):**
```json
{
  "success": true,
  "escpos": "base64_encoded_escpos_bitmap",
  "size": 12345
}
```

**Response (Error):**
```json
{
  "success": false,
  "error": "HTTP 404"
}
```

**Process Flow:**
1. Download image from URL (supports HTTP/HTTPS)
2. Resize image to fit thermal printer constraints
3. Convert to grayscale
4. Apply monochrome threshold
5. Generate ESC/POS bitmap command (`GS v 0`)
6. Return base64-encoded ESC/POS data

#### `GET /test-print`
**Purpose:** Send a test print to verify printer functionality

**Response:**
```
"Test sent. JobID: 12345"
```

**Test Print Content:**
- Printer initialization
- Centered "TEST PRINT" text
- Separator line
- Paper cut command

---

## Image Processing Algorithm

### Logo Conversion Process (`imageToEscPosBitmap`)

**Input:** Image buffer (PNG, JPG, etc.)
**Output:** ESC/POS bitmap command buffer

**Steps:**

1. **Load & Analyze**
   - Load image using Sharp library
   - Extract metadata (width, height, format)

2. **Resize with Aspect Ratio**
   ```
   - If width > LOGO_MAX_WIDTH (384px):
       width = 384px
       height = proportional

   - If height > LOGO_MAX_HEIGHT (150px):
       height = 150px
       width = proportional
   ```

3. **Convert to Grayscale**
   - Convert all pixels to single-channel grayscale (0-255)

4. **Monochrome Conversion**
   - Apply threshold: `pixel < 128 ? BLACK : WHITE`
   - Pack 8 pixels into 1 byte (MSB first)

5. **ESC/POS Command Generation**
   ```
   Structure: GS v 0 m xL xH yL yH [bitmap data]

   GS = 0x1D (Group Separator)
   v = 0x76 (Print raster bit image)
   0 = 0x30 (Mode 0: normal)
   m = 0x00 (Mode parameter)
   xL, xH = Width in bytes (little-endian)
   yL, yH = Height in pixels (little-endian)
   ```

6. **Add Formatting**
   - Center alignment command: `ESC a 1`
   - Line feed after image: `0x0A`
   - Reset to left alignment: `ESC a 0`

---

## Network Configuration

### Server Binding
- **Host:** `0.0.0.0` (all network interfaces)
- **Port:** `9191`

### Local Access
```
http://localhost:9191
```

### Network Access
```
http://[LOCAL_IP]:9191
```

**IP Discovery:**
The server automatically detects and displays the local IP address on startup using the `getLocalIPAddress()` function, which scans network interfaces for non-internal IPv4 addresses.

### Firewall Requirements
- **Inbound Rule:** Allow TCP port 9191
- **Required for:** Network printing from remote devices

---

## Build & Deployment

### Development Mode

**Start Server:**
```bash
npm start
# or
node printServer.js
```

**Requirements:**
- Node.js installed
- `npm install` completed

### Production Build

**Build Windows Executable (x64):**
```bash
npm run build
```

**Output:** `dist/PrintServer.exe` (64-bit)

**Build Windows Executable (x86):**
```bash
npm run build-x86
```

**Output:** `dist/PrintServer-x86.exe` (32-bit)

### Packaging Configuration (`pkg`)

**Included Assets:**
- `node_modules/@thiagoelg/node-printer/**/*` - Printer native bindings
- `node_modules/sharp/**/*` - Image processing binaries

**Compression:** GZip

**Node.js Runtime:** v18 (bundled)

---

## Deployment Package Structure

```
dist/
├── PrintServer.exe              # Main executable (42MB)
├── sharp/                       # Native image processing libraries (REQUIRED)
├── README.txt                   # Basic deployment guide
├── DEPLOYMENT_GUIDE.txt         # Detailed deployment instructions
├── INSTALLER_README.txt         # Installer documentation
├── QUICK_START_GUIDE.txt        # Quick start reference
├── INSTALL.bat                  # Quick installer script
├── INSTALL_AUTO_START.bat       # Auto-start installation
├── INSTALL_SERVICE.bat          # Windows service installation
├── UNINSTALL_AUTO_START.bat     # Remove auto-start
├── UNINSTALL_SERVICE.bat        # Remove Windows service
├── START_SERVER_MANUAL.bat      # Manual start script
├── CHECK_STATUS.bat             # Check server status
├── SERVICE_STATUS.bat           # Check Windows service status
├── ADD_TO_STARTUP.bat           # Add to Windows startup
├── PrintServerInstaller.ps1     # PowerShell installer
├── Uninstall-PrintServer.ps1    # PowerShell uninstaller
└── nssm.zip                     # NSSM (Non-Sucking Service Manager)
```

### Deployment Requirements

**CRITICAL:** The entire `dist/` folder must be deployed as a unit. The `sharp/` folder contains native binaries that MUST be in the same directory as `PrintServer.exe`.

**System Requirements:**
- Windows 7/8/10/11 (64-bit or 32-bit depending on build)
- Thermal printer with Windows driver installed
- Network connection (for network printing)
- No Node.js or npm required (bundled in executable)

---

## Installation Methods

### Method 1: Manual Start (Simple)
1. Copy entire `dist/` folder to target machine
2. Run `INSTALL.bat` or double-click `PrintServer.exe`
3. Server runs in console window

### Method 2: Auto-Start on Login
1. Run `INSTALL_AUTO_START.bat`
2. Server starts automatically when user logs in
3. Use `UNINSTALL_AUTO_START.bat` to remove

### Method 3: Windows Service
1. Run `INSTALL_SERVICE.bat` as Administrator
2. Server runs as background Windows service
3. Starts automatically on system boot
4. Use `UNINSTALL_SERVICE.bat` to remove

---

## ESC/POS Protocol Support

### Supported Commands

**Initialization:**
- `ESC @` (0x1B 0x40) - Initialize printer

**Text Alignment:**
- `ESC a n` (0x1B 0x61 n)
  - n=0: Left align
  - n=1: Center
  - n=2: Right align

**Graphics:**
- `GS v 0 m xL xH yL yH [data]` - Print raster bitmap
  - Used for logo printing

**Paper Control:**
- `LF` (0x0A) - Line feed
- `GS V 1` (0x1D 0x56 0x01) - Full paper cut

---

## Security Considerations

### Current Implementation
- **No Authentication:** Open HTTP endpoints
- **No Encryption:** Plain HTTP (not HTTPS)
- **CORS:** Enabled for all origins

### Recommended for Production
1. **Network Isolation:** Run on isolated internal network
2. **Firewall Rules:** Restrict access to trusted IPs
3. **VPN:** Use VPN for remote access
4. **API Gateway:** Add authentication layer if internet-exposed

### Data Validation
- URL validation for logo downloads
- Base64 decoding error handling
- Printer name validation

---

## Logging & Monitoring

### Console Output

**Server Startup:**
```
========================================
🖨️  Print Server (Logo Cache Mode)
========================================
Local:   http://localhost:9191
Network: http://192.168.1.100:9191
Printer: RP3160
Logo Max Size: 384x150px

Endpoints:
  POST /convert-logo  - Convert logo (one-time)
  POST /print         - Print ESC/POS
  GET  /ping          - Discovery
  GET  /status        - Printer status
  GET  /printers      - List printers
  GET  /test-print    - Test print
========================================
```

**Logo Conversion:**
```
========================================
🖼️  Logo Conversion Request
URL: https://example.com/logo.png
========================================
📥 Downloading...
✅ Downloaded: 45678 bytes
🖼️  Processing image...
   Original: 800x600
   Resized: 384x288
   Bitmap: 13824 bytes
✅ ESC/POS: 13856 bytes
✅ Conversion complete
========================================
```

**Print Request:**
```
========================================
📥 Print Request
Printer: RP3160
Encoding: base64
Data length: 1234
========================================
✅ Decoded: 1234 bytes
✅ Print successful. JobID: 567
========================================
```

---

## Troubleshooting

### Common Issues

| Problem | Cause | Solution |
|---------|-------|----------|
| "Cannot find module 'sharp'" | Missing sharp folder | Ensure `sharp/` folder is in same directory as .exe |
| "Printer not found" | Wrong printer name or printer offline | Check `/printers` endpoint, verify printer driver installed |
| Can't access from network | Windows Firewall blocking | Allow TCP port 9191 in Windows Firewall |
| Logo conversion fails | No internet access | Ensure server can reach logo URL |
| Print job sent but nothing prints | Printer driver issue | Check printer status, restart printer |
| Server won't start on port 9191 | Port already in use | Close other instances or change PORT constant |

### Diagnostic Endpoints

```bash
# Check server is running
curl http://localhost:9191/

# Get printer status
curl http://localhost:9191/status

# List all printers
curl http://localhost:9191/printers

# Send test print
curl http://localhost:9191/test-print
```

---

## Performance Characteristics

### Image Processing
- **Average logo conversion time:** 500-2000ms (depends on image size)
- **Memory usage:** ~50-100MB during image processing
- **Supported formats:** PNG, JPG, GIF, WebP, TIFF, SVG

### Print Speed
- **Network latency:** ~50-200ms (local network)
- **Print job submission:** <100ms
- **Actual printing speed:** Depends on thermal printer hardware

### Concurrency
- Express.js handles concurrent requests asynchronously
- No request queuing implemented (printer driver handles job queue)

---

## Integration Examples

### JavaScript (Fetch API)

```javascript
// Print ESC/POS data
fetch('http://192.168.1.100:9191/print', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    escpos: 'base64_encoded_data',
    printerName: 'RP3160',
    encoding: 'base64'
  })
})
.then(res => res.json())
.then(data => console.log('Print job:', data.jobID));

// Convert logo (one-time)
fetch('http://192.168.1.100:9191/convert-logo', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    logoUrl: 'https://example.com/logo.png'
  })
})
.then(res => res.json())
.then(data => {
  // Cache data.escpos in localStorage
  localStorage.setItem('logoEscpos', data.escpos);
});
```

### Python

```python
import requests
import base64

# Convert logo
response = requests.post('http://192.168.1.100:9191/convert-logo', json={
    'logoUrl': 'https://example.com/logo.png'
})
logo_escpos = response.json()['escpos']

# Print
requests.post('http://192.168.1.100:9191/print', json={
    'escpos': logo_escpos,
    'printerName': 'RP3160',
    'encoding': 'base64'
})
```

### cURL

```bash
# Convert logo
curl -X POST http://192.168.1.100:9191/convert-logo \
  -H "Content-Type: application/json" \
  -d '{"logoUrl":"https://example.com/logo.png"}'

# Print
curl -X POST http://192.168.1.100:9191/print \
  -H "Content-Type: application/json" \
  -d '{"escpos":"base64_data","printerName":"RP3160","encoding":"base64"}'
```

---

## Future Enhancement Possibilities

- [ ] HTTPS support with SSL certificates
- [ ] Authentication & API keys
- [ ] Print job queue management
- [ ] WebSocket support for real-time status updates
- [ ] Multi-printer support (dynamic printer selection)
- [ ] Print job history and logging
- [ ] Web-based admin panel
- [ ] PDF to ESC/POS conversion
- [ ] Template-based receipt generation
- [ ] QR code generation support

---

## File Structure Summary

```
printer-server/
├── printServer.js              # Main application source
├── package.json                # Dependencies & build scripts
├── package-lock.json           # Locked dependency versions
├── node_modules/               # Installed dependencies
├── dist/                       # Build output (executables & deployment files)
│   ├── PrintServer.exe
│   ├── sharp/
│   └── *.bat, *.ps1, *.txt
└── SYSTEM_DOCUMENTATION.md     # This file
```

---

## Technology Stack Summary

| Layer | Technology |
|-------|------------|
| Runtime | Node.js v18 |
| Web Framework | Express.js v5 |
| Image Processing | Sharp (libvips) |
| Printer Interface | node-printer (native binding) |
| Build Tool | pkg (Node.js packager) |
| Protocol | HTTP/REST |
| Printer Protocol | ESC/POS |
| Platform | Windows (x64/x86) |

---

## License & Credits

**Dependencies:**
- Express.js - MIT License
- Sharp - Apache 2.0 License
- node-printer - MIT License
- CORS - MIT License

---

**Documentation Version:** 1.0.0
**Last Updated:** 2026-01-31
**System Version:** 1.0.0
