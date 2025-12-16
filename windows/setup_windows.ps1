# setup_host_v4.ps1
# 4096Bytes WSL Environment Auto-Setup (Final Fix)
# Features: Admin Check, Docker/Virt Check, Encoding-Safe Detection, Migration, Network Config

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

function Check-Ubuntu-Exists {
    $raw = wsl --list --quiet 2>&1 | Out-String
    if ($raw -match "Ubuntu") { return $true }
    try {
        $proc = Start-Process -FilePath "wsl" -ArgumentList "-d", "Ubuntu", "-e", "true" -NoNewWindow -PassThru -Wait -ErrorAction SilentlyContinue
        if ($proc.ExitCode -eq 0) { return $true }
    } catch {}
    
    return $false
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

# 1.3 Check Virtualization (Docker Specific)
$useDocker = Read-Host "Do you plan to use Docker? (Y/N)"

if ($useDocker -eq 'Y' -or $useDocker -eq 'y') {
    Write-Host " -> Checking Virtualization support for Docker..." -ForegroundColor Gray
    try {
        $sysInfo = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop
        if ($sysInfo.HypervisorPresent) {
            Print-Success "Virtualization is Enabled (Ready for Docker)."
        } else {
            Print-Error "Virtualization is DISABLED in BIOS!"
            Write-Host " -> Docker requires Virtualization."
            Pause
            Exit
        }
    } catch {
        Print-Warning "Could not detect Virtualization via WMI. Assuming enabled."
    }
} else {
    Write-Host " -> Skipping Virtualization check." -ForegroundColor Gray
}

# ==========================================
# Step 2/4: WSL & Ubuntu Installation
# ==========================================
Print-Header "Step 2/4: WSL & Ubuntu Installation"

$needsReboot = $false
$wslInstalled = (Get-Command "wsl.exe" -ErrorAction SilentlyContinue)

$ubuntuExists = Check-Ubuntu-Exists

if ($wslInstalled -and $ubuntuExists) {
    Print-Success "WSL Core and Ubuntu subsystem are detected."
} elseif ($wslInstalled -and -not $ubuntuExists) {
    Print-Warning "WSL Core detected, but Ubuntu is missing."
    Write-Host " -> Installing Ubuntu subsystem..."
    
    try {
        wsl --install -d Ubuntu
    } catch {
        Write-Host " -> Log: Installation command finished." -ForegroundColor Gray
    }

    # Re-check
    if (Check-Ubuntu-Exists) {
        Print-Success "Ubuntu is ready."
    } else {
        Print-Error "Installation failed or could not be verified."
        Pause
        Exit
    }
} else {
    Print-Warning "WSL is NOT installed."
    Write-Host " -> Installing WSL and Ubuntu..."
    $null = Read-Host "Press Enter to start installation..."
    wsl --install
    Print-Success "WSL Base and Ubuntu installed!"
    $needsReboot = $true
}

if ($needsReboot) {
    Print-Warning "System reboot is required."
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
    # Migration Logic with Safety Check
    if (Check-Ubuntu-Exists) {
        Print-Warning "Moving Ubuntu from C: to D: ..."
        Write-Host " -> This is a high IO operation. Do not force quit."
        
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
        Print-Error "Ubuntu not detected. Cannot migrate."
        Write-Host " -> Please run 'wsl' manually once to initialize it."
        Pause
        Exit
    }
}

# ==========================================
# Step 4/4: Network Configuration
# ==========================================
Print-Header "Step 4/4: Network Configuration"

if ($isWin11) {
    Write-Host "Windows 11 detected. We recommend 'Mirrored Mode'."
    $netChoice = Read-Host "Enable Mirrored Network Mode? (Y/N)"
    
    if ($netChoice -eq 'Y' -or $netChoice -eq 'y') {
        $configContent = @"
[wsl2]
networkingMode=mirrored
dnsTunneling=true
autoProxy=true
"@
        $configContent | Out-File -FilePath $WSL_CONFIG_PATH -Encoding ASCII
        Print-Success "Configured: Mirrored Mode"
    } else {
        if (Test-Path $WSL_CONFIG_PATH) { Remove-Item $WSL_CONFIG_PATH }
        Print-Success "Configured: Traditional NAT Mode"
    }
} else {
    if (Test-Path $WSL_CONFIG_PATH) { Remove-Item $WSL_CONFIG_PATH }
    Print-Success "Old configurations cleaned."
}

# ==========================================
# Finish
# ==========================================
Print-Header "SETUP COMPLETE!"

Write-Host "Recommendation: Install 'Windows Terminal'."
Write-Host "Link: $LINK_TERMINAL" -ForegroundColor Blue
Write-Host ""

$startChoice = Read-Host "Start Ubuntu now? (Y/N)"
if ($startChoice -eq 'Y' -or $startChoice -eq 'y') {
    wsl -d Ubuntu
} else {
    Pause
}
