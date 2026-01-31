# Print Server - Portable Bundle Builder
$ErrorActionPreference = "Stop"

Write-Host "Building Print Server Portable Bundle..." -ForegroundColor Cyan

$OutputDir = "PrintServer-Portable"
$NodeVersion = "20.11.0"
$NodeURL = "https://nodejs.org/dist/v$NodeVersion/node-v$NodeVersion-win-x64.zip"

# Clean output
if (Test-Path $OutputDir) { Remove-Item $OutputDir -Recurse -Force }
New-Item -ItemType Directory -Path $OutputDir | Out-Null

# Copy files
Write-Host "Copying files..." -ForegroundColor Yellow
Copy-Item "printServer.js" -Destination $OutputDir
Copy-Item "package.json" -Destination $OutputDir
Copy-Item "Start-PrintServer.bat" -Destination $OutputDir
Copy-Item "Stop-PrintServer.bat" -Destination $OutputDir
Copy-Item "node_modules" -Destination "$OutputDir\node_modules" -Recurse

# Download Node.js
Write-Host "Downloading Node.js..." -ForegroundColor Yellow
Invoke-WebRequest -Uri $NodeURL -OutFile "node.zip"

# Extract
Write-Host "Extracting..." -ForegroundColor Yellow
Expand-Archive "node.zip" -DestinationPath "temp"
$folder = Get-ChildItem "temp" | Select-Object -First 1
Move-Item "temp\$folder" "$OutputDir\nodejs"

# Cleanup
Remove-Item "temp" -Recurse -Force
Remove-Item "node.zip"

Write-Host "Build complete! Output: $OutputDir" -ForegroundColor Green
