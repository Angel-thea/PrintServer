# Print Server Installer
# Professional installation script for Windows

param(
    [string]$PrinterName = "",
    [string]$InstallPath = "$env:ProgramFiles\PrintServer",
    [switch]$ConfigureFirewall = $true,
    [switch]$StartService = $true
)

$ErrorActionPreference = "Stop"

# Colors
$Color_Success = "Green"
$Color_Error = "Red"
$Color_Info = "Cyan"
$Color_Warning = "Yellow"

function Write-Header {
    param([string]$Text)
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
}

function Write-Step {
    param([string]$Text)
    Write-Host "[*] $Text" -ForegroundColor White
}

function Write-Success {
    param([string]$Text)
    Write-Host "[✓] $Text" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Text)
    Write-Host "[✗] $Text" -ForegroundColor Red
}

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Error-Custom "This installer must be run as Administrator!"
    Write-Host "`nPlease right-click this script and select 'Run as Administrator'" -ForegroundColor Yellow
    Read-Host "`nPress Enter to exit"
    exit 1
}

Write-Header "PRINT SERVER INSTALLER v1.0"

# Get current script directory
$SourceDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Check if PrintServer.exe exists
if (-not (Test-Path "$SourceDir\PrintServer.exe")) {
    Write-Error-Custom "PrintServer.exe not found in $SourceDir"
    Read-Host "`nPress Enter to exit"
    exit 1
}

# Ask for printer name if not provided
if ([string]::IsNullOrWhiteSpace($PrinterName)) {
    Write-Host "Available printers on this system:" -ForegroundColor Yellow
    Get-Printer | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor White }
    Write-Host "`nDefault printer name in code: RP3160" -ForegroundColor Yellow
    $PrinterName = Read-Host "`nEnter printer name (or press Enter to use RP3160)"
    if ([string]::IsNullOrWhiteSpace($PrinterName)) {
        $PrinterName = "RP3160"
    }
}

Write-Host "`nInstallation Settings:" -ForegroundColor Cyan
Write-Host "  Install Path:      $InstallPath" -ForegroundColor White
Write-Host "  Printer Name:      $PrinterName" -ForegroundColor White
Write-Host "  Configure Firewall: $ConfigureFirewall" -ForegroundColor White
Write-Host "  Start Service:     $StartService" -ForegroundColor White

$confirm = Read-Host "`nProceed with installation? (Y/N)"
if ($confirm -ne 'Y' -and $confirm -ne 'y') {
    Write-Host "Installation cancelled." -ForegroundColor Yellow
    exit 0
}

try {
    # Step 1: Create installation directory
    Write-Step "Creating installation directory..."
    if (-not (Test-Path $InstallPath)) {
        New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
    }
    Write-Success "Directory created: $InstallPath"

    # Step 2: Copy files
    Write-Step "Copying Print Server files..."
    Copy-Item "$SourceDir\PrintServer.exe" -Destination $InstallPath -Force

    if (Test-Path "$SourceDir\sharp") {
        Copy-Item "$SourceDir\sharp" -Destination $InstallPath -Recurse -Force
        Write-Success "Copied PrintServer.exe and sharp folder"
    } else {
        Write-Success "Copied PrintServer.exe"
    }

    # Step 3: Configure Windows Firewall
    if ($ConfigureFirewall) {
        Write-Step "Configuring Windows Firewall..."

        # Remove existing rule if it exists
        Remove-NetFirewallRule -DisplayName "Print Server" -ErrorAction SilentlyContinue

        # Add new firewall rule
        New-NetFirewallRule -DisplayName "Print Server" `
            -Direction Inbound `
            -Protocol TCP `
            -LocalPort 9191 `
            -Action Allow `
            -Profile Any `
            -Description "Allow Print Server on port 9191" | Out-Null

        Write-Success "Firewall rule created for port 9191"
    }

    # Step 4: Install as Windows Service using Task Scheduler
    Write-Step "Installing Windows Service..."

    # Remove existing task if it exists
    Unregister-ScheduledTask -TaskName "PrintServer" -Confirm:$false -ErrorAction SilentlyContinue

    # Create scheduled task action
    $action = New-ScheduledTaskAction -Execute "$InstallPath\PrintServer.exe" -WorkingDirectory $InstallPath

    # Create trigger (at startup)
    $trigger = New-ScheduledTaskTrigger -AtStartup

    # Create settings
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)

    # Create principal (run as SYSTEM)
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

    # Register the task
    Register-ScheduledTask -TaskName "PrintServer" `
        -Action $action `
        -Trigger $trigger `
        -Settings $settings `
        -Principal $principal `
        -Description "Print Server - Thermal Printer Service with Logo Support" | Out-Null

    Write-Success "Service installed successfully"

    # Step 5: Create Start Menu shortcut
    Write-Step "Creating shortcuts..."

    $WshShell = New-Object -ComObject WScript.Shell
    $StartMenuPath = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs"

    # Shortcut to start server manually
    $Shortcut = $WshShell.CreateShortcut("$StartMenuPath\Print Server.lnk")
    $Shortcut.TargetPath = "$InstallPath\PrintServer.exe"
    $Shortcut.WorkingDirectory = $InstallPath
    $Shortcut.Description = "Print Server"
    $Shortcut.Save()

    Write-Success "Start Menu shortcut created"

    # Step 6: Start the service
    if ($StartService) {
        Write-Step "Starting Print Server service..."
        Start-ScheduledTask -TaskName "PrintServer"
        Start-Sleep -Seconds 3
        Write-Success "Service started"

        # Test if server is responding
        Write-Step "Testing server connection..."
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:9191" -UseBasicParsing -TimeoutSec 5
            Write-Success "Server is responding!"
        } catch {
            Write-Warning "Server may still be starting up..."
        }
    }

    # Get local IP
    $LocalIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -like "*Wi-Fi*" -or $_.InterfaceAlias -like "*Ethernet*"} | Select-Object -First 1).IPAddress

    # Installation complete
    Write-Header "INSTALLATION COMPLETE!"

    Write-Host "Print Server has been successfully installed!`n" -ForegroundColor Green
    Write-Host "Installation Details:" -ForegroundColor Cyan
    Write-Host "  Location:        $InstallPath" -ForegroundColor White
    Write-Host "  Printer:         $PrinterName" -ForegroundColor White
    Write-Host "  Service:         Running (auto-start on boot)" -ForegroundColor White
    Write-Host "  Firewall:        Configured (port 9191)" -ForegroundColor White
    Write-Host "`nAccess URLs:" -ForegroundColor Cyan
    Write-Host "  Local:           http://localhost:9191" -ForegroundColor White
    Write-Host "  Network:         http://${LocalIP}:9191" -ForegroundColor White
    Write-Host "`nAvailable Endpoints:" -ForegroundColor Cyan
    Write-Host "  /                Health check" -ForegroundColor White
    Write-Host "  /ping            Discovery" -ForegroundColor White
    Write-Host "  /status          Printer status" -ForegroundColor White
    Write-Host "  /printers        List printers" -ForegroundColor White
    Write-Host "  /test-print      Test print" -ForegroundColor White
    Write-Host "  /print           Print ESC/POS" -ForegroundColor White
    Write-Host "  /convert-logo    Convert logo" -ForegroundColor White
    Write-Host "`nUninstall:" -ForegroundColor Cyan
    Write-Host "  Run: Uninstall-PrintServer.ps1" -ForegroundColor White
    Write-Host "  Or:  Add/Remove Programs > Print Server Files" -ForegroundColor White

    Write-Host "`n========================================`n" -ForegroundColor Cyan

} catch {
    Write-Header "INSTALLATION FAILED"
    Write-Error-Custom $_.Exception.Message
    Write-Host "`nPlease check the error above and try again." -ForegroundColor Yellow
    Read-Host "`nPress Enter to exit"
    exit 1
}

Read-Host "`nPress Enter to exit"
