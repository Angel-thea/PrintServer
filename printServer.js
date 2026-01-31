/**
 * Print Server with Logo Conversion Endpoint
 *
 * Features:
 * - /print - Receives ESC/POS commands and prints
 * - /convert-logo - Converts logo URL to ESC/POS (one-time, app caches result)
 *
 * Installation:
 * npm install express cors @thiagoelg/node-printer sharp
 *
 * Usage:
 * node printServer.js
 */

const express = require("express");
const cors = require("cors");
const printer = require("@thiagoelg/node-printer");
const sharp = require("sharp");
const https = require("https");
const http = require("http");
const os = require("os");

const app = express();
const PORT = 9191;

// IMPORTANT: Change this to match your printer name
const PRINTER_NAME = "RP3160"; // Use name from printer.getPrinters()

// Logo settings
const LOGO_MAX_WIDTH = 384; // Max width in pixels for 80mm printers
const LOGO_MAX_HEIGHT = 150; // Max height in pixels (reduced to prevent too tall logos)
const LOGO_THRESHOLD = 128; // Brightness threshold for monochrome (0-255)

app.use(cors());
app.use(express.json({ limit: '10mb' }));

/**
 * Get local IP address for display
 */
function getLocalIPAddress() {
  const interfaces = os.networkInterfaces();
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name]) {
      // Skip internal and non-IPv4 addresses
      if (iface.family === 'IPv4' && !iface.internal) {
        return iface.address;
      }
    }
  }
  return 'localhost';
}

// Health check
app.get("/", (req, res) => {
  res.send("Print Service with Logo Support is running");
});

// Ping endpoint
app.get("/ping", (req, res) => {
  res.json({
    status: "online",
    name: "Print Server",              // Server name
    printerModel: PRINTER_NAME,         // Printer name (for app discovery)
    printer: PRINTER_NAME,              // Legacy field
    logoSupport: true
  });
});

// Status endpoint
app.get("/status", (req, res) => {
  try {
    const printers = printer.getPrinters();
    const myPrinter = printers.find(p => p.name === PRINTER_NAME);

    res.json({
      online: !!myPrinter,
      name: "Print Server",              // Server name
      printerModel: PRINTER_NAME,         // Actual printer name (e.g., "RP3160")
      printerName: PRINTER_NAME,          // Legacy field
      available: printers.length > 0,
      logoSupport: true
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * Download image from URL
 */
async function downloadImage(url) {
  return new Promise((resolve, reject) => {
    const protocol = url.startsWith('https') ? https : http;

    protocol.get(url, (response) => {
      if (response.statusCode !== 200) {
        reject(new Error(`HTTP ${response.statusCode}`));
        return;
      }

      const chunks = [];
      response.on('data', (chunk) => chunks.push(chunk));
      response.on('end', () => resolve(Buffer.concat(chunks)));
      response.on('error', reject);
    }).on('error', reject);
  });
}

/**
 * Convert image to ESC/POS bitmap commands
 */
async function imageToEscPosBitmap(imageBuffer, maxWidth = LOGO_MAX_WIDTH) {
  console.log(`🖼️  Processing image...`);

  // Resize and convert to grayscale
  const image = sharp(imageBuffer);
  const metadata = await image.metadata();

  console.log(`   Original: ${metadata.width}x${metadata.height}`);

  // Maintain aspect ratio with both width and height constraints
  let width = Math.min(metadata.width, maxWidth);
  let height = Math.floor((metadata.height / metadata.width) * width);

  // If height exceeds max, scale down based on height
  if (height > LOGO_MAX_HEIGHT) {
    height = LOGO_MAX_HEIGHT;
    width = Math.floor((metadata.width / metadata.height) * height);
  }

  console.log(`   Resized: ${width}x${height}`);

  // Get grayscale pixel data
  const resized = await image
    .resize(width, height, { fit: 'inside' })
    .grayscale()
    .raw()
    .toBuffer({ resolveWithObject: true });

  const pixels = resized.data;
  const pixelWidth = resized.info.width;
  const pixelHeight = resized.info.height;

  // Convert to monochrome bitmap (1 bit per pixel)
  const widthBytes = Math.ceil(pixelWidth / 8);
  const bitmap = [];

  for (let y = 0; y < pixelHeight; y++) {
    for (let xByte = 0; xByte < widthBytes; xByte++) {
      let byte = 0;

      for (let bit = 0; bit < 8; bit++) {
        const x = xByte * 8 + bit;

        if (x < pixelWidth) {
          const pixelIndex = y * pixelWidth + x;
          const gray = pixels[pixelIndex];

          // Black if below threshold
          const isBlack = gray < LOGO_THRESHOLD ? 1 : 0;

          // Set bit (MSB first)
          byte |= isBlack << (7 - bit);
        }
      }

      bitmap.push(byte);
    }
  }

  console.log(`   Bitmap: ${bitmap.length} bytes`);

  // Generate ESC/POS: GS v 0 m xL xH yL yH d1...dk
  const GS = 0x1D;
  const mode = 0; // Normal size

  const xL = widthBytes & 0xFF;
  const xH = (widthBytes >> 8) & 0xFF;
  const yL = pixelHeight & 0xFF;
  const yH = (pixelHeight >> 8) & 0xFF;

  // Build command
  const escposCommand = Buffer.concat([
    Buffer.from([0x1B, 0x61, 0x01]), // Center align
    Buffer.from([GS, 0x76, 0x30, mode, xL, xH, yL, yH]), // Image
    Buffer.from(bitmap), // Data
    Buffer.from([0x0A]), // Line feed
    Buffer.from([0x1B, 0x61, 0x00]), // Left align
  ]);

  console.log(`✅ ESC/POS: ${escposCommand.length} bytes`);

  return escposCommand;
}

/**
 * Convert logo endpoint (one-time, app caches result)
 * POST /convert-logo
 * Body: { logoUrl: "https://..." }
 * Returns: { success: true, escpos: "base64..." }
 */
app.post("/convert-logo", async (req, res) => {
  const { logoUrl } = req.body;

  console.log('========================================');
  console.log('🖼️  Logo Conversion Request');
  console.log('URL:', logoUrl);
  console.log('========================================');

  if (!logoUrl) {
    return res.status(400).json({ error: "Missing logoUrl" });
  }

  try {
    // Download image
    console.log('📥 Downloading...');
    const imageData = await downloadImage(logoUrl);
    console.log(`✅ Downloaded: ${imageData.length} bytes`);

    // Convert to ESC/POS
    const escposBuffer = await imageToEscPosBitmap(imageData);

    // Return as base64
    const escposBase64 = escposBuffer.toString('base64');

    console.log('✅ Conversion complete');
    console.log('========================================');

    res.json({
      success: true,
      escpos: escposBase64,
      size: escposBuffer.length
    });
  } catch (error) {
    console.error('❌ Conversion failed:', error.message);
    console.log('========================================');

    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

/**
 * Print endpoint - receives ESC/POS commands
 * POST /print
 * Body: { escpos: "base64...", printerName: "RP3160", encoding: "base64" }
 */
app.post("/print", async (req, res) => {
  const { escpos, printerName, encoding } = req.body;

  console.log('========================================');
  console.log('📥 Print Request');
  console.log('Printer:', printerName || PRINTER_NAME);
  console.log('Encoding:', encoding);
  console.log('Data length:', escpos ? escpos.length : 0);
  console.log('========================================');

  if (!escpos) {
    return res.status(400).json({ error: "Missing ESC/POS data" });
  }

  try {
    // Decode ESC/POS
    let buffer;
    if (encoding === 'base64') {
      buffer = Buffer.from(escpos, 'base64');
      console.log(`✅ Decoded: ${buffer.length} bytes`);
    } else {
      buffer = Buffer.from(escpos, 'binary');
      console.log(`✅ Decoded: ${buffer.length} bytes`);
    }

    const printerToUse = printerName || PRINTER_NAME;

    // Print
    printer.printDirect({
      data: buffer,
      printer: printerToUse,
      type: "RAW",
      success: (jobID) => {
        console.log(`✅ Print successful. JobID: ${jobID}`);
        console.log('========================================');
        res.json({ success: true, jobID });
      },
      error: (err) => {
        console.error(`❌ Print failed: ${err.message}`);
        console.log('========================================');
        res.status(500).json({ error: err.message });
      },
    });
  } catch (err) {
    console.error(`❌ Error: ${err.message}`);
    console.log('========================================');
    res.status(500).json({ error: err.message });
  }
});

// Test print
app.get("/test-print", (req, res) => {
  const test =
    "\x1B\x40" + // Init
    "\x1B\x61\x01" + // Center
    "TEST PRINT\n" +
    "\x1B\x61\x00" + // Left
     '======================\n\n\n\n\n\n' + // Extra space before cut
    "\x1D\x56\x01"; // Cut

  const buffer = Buffer.from(test, 'binary');

  printer.printDirect({
    data: buffer,
    printer: PRINTER_NAME,
    type: "RAW",
    success: (jobID) => res.send(`Test sent. JobID: ${jobID}`),
    error: (err) => res.status(500).send(`Failed: ${err.message}`),
  });
});

// List printers
app.get("/printers", (req, res) => {
  try {
    const printers = printer.getPrinters();
    res.json({ printers });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Start server
app.listen(PORT, "0.0.0.0", () => {
  const ip = getLocalIPAddress();
  console.log("========================================");
  console.log("🖨️  Print Server (Logo Cache Mode)");
  console.log("========================================");
  console.log(`Local:   http://localhost:${PORT}`);
  console.log(`Network: http://${ip}:${PORT}`);
  console.log(`Printer: ${PRINTER_NAME}`);
  console.log(`Logo Max Size: ${LOGO_MAX_WIDTH}x${LOGO_MAX_HEIGHT}px`);
  console.log("");
  console.log("Endpoints:");
  console.log("  POST /convert-logo  - Convert logo (one-time)");
  console.log("  POST /print         - Print ESC/POS");
  console.log("  GET  /ping          - Discovery");
  console.log("  GET  /status        - Printer status");
  console.log("  GET  /printers      - List printers");
  console.log("  GET  /test-print    - Test print");
  console.log("========================================");
});
