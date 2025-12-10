# setup_host.ps1
# 4096Bytes WSL Environment Auto-Setup (English Version + Virt Check)
# Features: Admin Check, Virt Check, WSL Install, D-Drive Migration, Network Config

$ErrorActionPreference = "Stop"

# === Configuration ===
$WSL_DIR = "D:\WSL\Ubuntu"
$BACKUP_FILE = "D:\ubuntu-backup.tar"
$WSL_CONFIG_PATH = "$env:USERPROFILE\.wslconfig"
$LINK_TERMINAL = "https://apps.microsoft.com/detail/9n0dx20hk701?hl=en-us&gl=US"
$LINK_VIRT = "https://support.microsoft.com/en-us/windows/enable-virtualization-on-windows-c5578302-6e43-4b4b-a449-8ced115f58e1"

# === Helper Functions ===
function Print-Header {
    param($text)
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host $text -ForegroundColor Cyan
    Write-Host "========================================"
}

function Print-Success {
    param($text)
    Write-Host " [OK] $text" -ForegroundColor Green
}

function Print-Error {
    param($text)
    Write-Host " [ERROR] $text" -ForegroundColor Red
}

function Print-Warning {
    param($text)
    Write-Host " [WARN] $text" -ForegroundColor Yellow
}

# ==========================================
# Step 1/4: Pre-check
# ==========================================
Print-Header "Step 1/4: Environment Pre-check"

# 1.1 Check Admin Rights
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Print-Error "Admin rights required!"
    Write-Host " -> Please right-click this script and select 'Run with PowerShell' as Administrator."
    Pause
    Exit
}

# 1.2 Check OS Version
$osVersion = Get-CimInstance Win32_OperatingSystem
$buildNumber = [int]$osVersion.BuildNumber
$isWin11 = $buildNumber -ge 22000

if ($isWin11) {
    Print-Success "OS: Windows 11 (Build ${buildNumber})"
} else {
    Print-Success "OS: Windows 10 (Build ${buildNumber})"
}

# 1.3 Check Virtualization (Robust Mode)
Write-Host " -> Checking Virtualization support..." -ForegroundColor Gray
try {
    # Use ErrorAction Stop to catch potential WMI errors
    $sysInfo = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop
    
    if ($sysInfo.HypervisorPresent) {
        Print-Success "Virtualization is Enabled."
    } else {
        Print-Error "Virtualization is DISABLED in BIOS!"
        Write-Host " -> WSL cannot run without Virtualization (VT-x / AMD-V)."
        Write-Host " -> Guide: $LINK_VIRT"
        Pause
        Exit
    }
} catch {
    # If checking fails (e.g. WMI corruption), do not crash. Warn and continue.
    Print-Warning "Could not automatically detect Virtualization status."
    Write-Host " -> Error details: $($_.Exception.Message)"
    Write-Host " -> Assuming it is enabled (since you verified it manually). Continuing..."
}

# ==========================================
# Step 2/4: WSL Installation
# ==========================================
Print-Header "Step 2/4: WSL Installation"

if (wsl --status) {
    Print-Success "WSL is already installed."
} else {
    Print-Warning "Installing Ubuntu... This depends on your internet speed."
    Write-Host " -> DO NOT close this window."
    
    $null = Read-Host "Press Enter to start installation..."
    
    wsl --install
    
    Print-Success "WSL Base installed!"
    Print-Warning "System reboot is required."
    Write-Host " -> Please reboot your computer manually."
    Write-Host " -> After reboot, run this script again to continue migration."
    Pause
    Exit
}

# ==========================================
# Step 3/4: Migration (C -> D)
# ==========================================
Print-Header "Step 3/4: Migration to D Drive"

if (Test-Path $WSL_DIR) {
    Print-Success "Target directory exists (${WSL_DIR}). Skipping migration."
} else {
    Print-Warning "Moving Ubuntu from C: to D: ..."
    Write-Host " -> This is a high IO operation. Do not force quit."
    
    # Ensure Shutdown
    wsl --shutdown
    
    Write-Host " [1/3] Exporting system image..."
    wsl --export Ubuntu $BACKUP_FILE
    
    Write-Host " [2/3] Unregistering old system..."
    wsl --unregister Ubuntu
    
    Write-Host " [3/3] Importing to new location..."
    New-Item -ItemType Directory -Force -Path $WSL_DIR | Out-Null
    wsl --import Ubuntu $WSL_DIR $BACKUP_FILE --version 2
    
    Remove-Item $BACKUP_FILE
    Print-Success "Migration complete!"
}

# ==========================================
# Step 4/4: Network Configuration
# ==========================================
Print-Header "Step 4/4: Network Configuration"

if ($isWin11) {
    # Win11 Logic
    Write-Host "Windows 11 detected. We recommend 'Mirrored Mode'."
    Write-Host " * Pros: Shared VPN IP, localhost access."
    Write-Host " * Cons: Minor compatibility issues with specific VPN clients."
    
    $netChoice = Read-Host "Enable Mirrored Network Mode? (Y/N)"
    
    if ($netChoice -eq 'Y' -or $netChoice -eq 'y') {
        $configContent = @"
[wsl2]
networkingMode=mirrored
dnsTunneling=true
autoProxy=true
"@
        $configContent | Out-File -FilePath $WSL_CONFIG_PATH -Encoding ASCII
        Print-Success "Configured: Mirrored Mode (Host IP = 127.0.0.1)"
    } else {
        if (Test-Path $WSL_CONFIG_PATH) { Remove-Item $WSL_CONFIG_PATH }
        Print-Success "Configured: Traditional NAT Mode"
    }
} else {
    # Win10 Logic
    Print-Warning "Windows 10 detected. Forcing Traditional NAT Mode."
    if (Test-Path $WSL_CONFIG_PATH) { Remove-Item $WSL_CONFIG_PATH }
    Print-Success "Old configurations cleaned."
}

# ==========================================
# Finish
# ==========================================
Print-Header "SETUP COMPLETE!"

Write-Host "Recommendation:" -ForegroundColor Cyan
Write-Host " -> Install 'Windows Terminal' from Microsoft Store for best experience."
Write-Host " -> Link: $LINK_TERMINAL" -ForegroundColor Blue
Write-Host ""

$startChoice = Read-Host "Start Ubuntu now? (Y/N)"
if ($startChoice -eq 'Y' -or $startChoice -eq 'y') {
    Write-Host "Starting Ubuntu..."
    wsl -d Ubuntu
} else {
    Write-Host "Script finished. Type 'wsl' in CMD to start later."
    Pause
}