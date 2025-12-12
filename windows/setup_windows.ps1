# setup_host_v2.ps1
# 4096Bytes WSL Environment Auto-Setup (Modified Version)
# Features: Admin Check, Docker/Virt Check, Smart WSL/Ubuntu Install, Migration, Network Config

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

# 1.3 Check Virtualization (Modified: Docker Specific)
# Only check virtualization if the user explicitly wants to use Docker.
$useDocker = Read-Host "Do you plan to use Docker? (Y/N)"

if ($useDocker -eq 'Y' -or $useDocker -eq 'y') {
    Write-Host " -> Checking Virtualization support for Docker..." -ForegroundColor Gray
    try {
        $sysInfo = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop
        
        if ($sysInfo.HypervisorPresent) {
            Print-Success "Virtualization is Enabled (Ready for Docker)."
        } else {
            Print-Error "Virtualization is DISABLED in BIOS!"
            Write-Host " -> Docker requires Virtualization (VT-x / AMD-V)."
            Write-Host " -> Guide: $LINK_VIRT"
            Pause
            Exit
        }
    } catch {
        Print-Warning "Could not detect Virtualization status via WMI."
        Write-Host " -> Assuming enabled based on manual verification. Continuing..."
    }
} else {
    Write-Host " -> Skipping Virtualization check (User opted out of Docker)." -ForegroundColor Gray
}

# ==========================================
# Step 2/4: WSL & Ubuntu Installation (Fixed)
# ==========================================
Print-Header "Step 2/4: WSL & Ubuntu Installation"

# Define a variable to track if we need to reboot
$needsReboot = $false

# Initialize states
$wslInstalled = $false
$ubuntuInstalled = $false

# 1. Check if 'wsl.exe' exists in the System Path
if (Get-Command "wsl.exe" -ErrorAction SilentlyContinue) {
    $wslInstalled = $true
    
    # 2. Check installed distributions
    # Capture output to string. '2>&1' ensures errors don't leak to console.
    $wslOutput = wsl --list --verbose 2>&1 | Out-String
    
    # 3. Check for "Ubuntu" keyword (case-insensitive)
    if ($wslOutput -match "Ubuntu") {
        $ubuntuInstalled = $true
    }
}

# Debug Info (Optional - helps you confirm what script sees)
# Write-Host "DEBUG: WSL Detected: $wslInstalled | Ubuntu Detected: $ubuntuInstalled" -ForegroundColor DarkGray

# Installation Logic
if ($wslInstalled -and $ubuntuInstalled) {
    Print-Success "WSL Core and Ubuntu subsystem are already installed."
} elseif ($wslInstalled -and -not $ubuntuInstalled) {
    Print-Warning "WSL Core detected, but Ubuntu is missing."
    Write-Host " -> Installing Ubuntu subsystem..."
    wsl --install -d Ubuntu
    Print-Success "Ubuntu installed."
} else {
    Print-Warning "WSL is NOT installed."
    Write-Host " -> Installing WSL and Ubuntu... This depends on your internet speed."
    Write-Host " -> DO NOT close this window."
    
    $null = Read-Host "Press Enter to start installation..."
    
    wsl --install
    
    Print-Success "WSL Base and Ubuntu installed!"
    $needsReboot = $true
}

if ($needsReboot) {
    Print-Warning "System reboot is required to finalize WSL installation."
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
    # Double check if Ubuntu is actually running/registered before export
    if (wsl --list --quiet | Select-String "Ubuntu") {
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
    } else {
        Print-Error "Ubuntu not found in WSL list. Cannot migrate."
        Write-Host " -> Please ensure Ubuntu is installed and initialized at least once."
        Pause
        Exit
    }
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

