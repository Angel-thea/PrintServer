# Print Server Uninstaller

$ErrorActionPreference = "Stop"

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "[✗] This uninstaller must be run as Administrator!" -ForegroundColor Red
    Write-Host "`nPlease right-click this script and select 'Run as Administrator'" -ForegroundColor Yellow
    Read-Host "`nPress Enter to exit"
    exit 1
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  PRINT SERVER UNINSTALLER" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$confirm = Read-Host "Are you sure you want to uninstall Print Server? (Y/N)"
if ($confirm -ne 'Y' -and $confirm -ne 'y') {
    Write-Host "Uninstall cancelled." -ForegroundColor Yellow
    exit 0
}

try {
    $InstallPath = "$env:ProgramFiles\PrintServer"

    # Stop the service
    Write-Host "[*] Stopping Print Server service..." -ForegroundColor White
    Stop-ScheduledTask -TaskName "PrintServer" -ErrorAction SilentlyContinue

    # Kill any running processes
    Get-Process -Name "PrintServer" -ErrorAction SilentlyContinue | Stop-Process -Force
    Write-Host "[✓] Service stopped" -ForegroundColor Green

    # Remove scheduled task
    Write-Host "[*] Removing Windows Service..." -ForegroundColor White
    Unregister-ScheduledTask -TaskName "PrintServer" -Confirm:$false -ErrorAction SilentlyContinue
    Write-Host "[✓] Service removed" -ForegroundColor Green

    # Remove firewall rule
    Write-Host "[*] Removing firewall rule..." -ForegroundColor White
    Remove-NetFirewallRule -DisplayName "Print Server" -ErrorAction SilentlyContinue
    Write-Host "[✓] Firewall rule removed" -ForegroundColor Green

    # Remove shortcuts
    Write-Host "[*] Removing shortcuts..." -ForegroundColor White
    Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Print Server.lnk" -ErrorAction SilentlyContinue
    Write-Host "[✓] Shortcuts removed" -ForegroundColor Green

    # Remove installation directory
    Write-Host "[*] Removing installation files..." -ForegroundColor White
    if (Test-Path $InstallPath) {
        Start-Sleep -Seconds 2  # Give time for processes to fully stop
        Remove-Item -Path $InstallPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "[✓] Files removed from $InstallPath" -ForegroundColor Green
    }

    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "  UNINSTALLATION COMPLETE!" -ForegroundColor Green
    Write-Host "========================================`n" -ForegroundColor Green

    Write-Host "Print Server has been successfully removed from your system.`n" -ForegroundColor White

} catch {
    Write-Host "`n[✗] Uninstallation error: $($_.Exception.Message)" -ForegroundColor Red
}

Read-Host "`nPress Enter to exit"
