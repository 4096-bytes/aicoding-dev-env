# setup_codex_config.ps1
# 4096Bytes - Codex configuration bootstrap (Windows PowerShell)
# Features:
# 1) Check Node.js environment and validate version >= 20
# 2) Install/Update Codex CLI globally: @openai/codex@latest
# 3) Prompt for 4096bytes API domain and API key
# 4) Write ~/.codex/config.toml and ~/.codex/auth.json

$ErrorActionPreference = "Stop"

function Write-Header {
    param($Text)
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host $Text -ForegroundColor Cyan
    Write-Host "========================================"
}

function Write-Ok { param($Text) Write-Host " [OK] $Text" -ForegroundColor Green }
function Write-Warn { param($Text) Write-Host " [WARN] $Text" -ForegroundColor Yellow }
function Write-Err { param($Text) Write-Host " [ERROR] $Text" -ForegroundColor Red }

Write-Header "4096Bytes - Codex Configuration"

# ==========================================
# 1) Check Node.js
# ==========================================
Write-Host "Step 1/3: Checking Node.js..."
$nodeCmd = Get-Command node -ErrorAction SilentlyContinue

if (-not $nodeCmd) {
    Write-Err "Node.js is not installed."
    Write-Host "Please install Node.js (20 or newer): https://nodejs.org/"
    exit 1
}

try {
    $rawVersion = (& node -v).Trim()   # e.g., v22.2.0
} catch {
    Write-Err "Failed to read Node.js version."
    exit 1
}

$nodeMajor = 0
if ($rawVersion -match '^v?(\d+)\.') {
    $nodeMajor = [int]$Matches[1]
}

if ($nodeMajor -lt 20) {
    Write-Err "Detected Node.js $rawVersion, but >= 20 is required."
    Write-Host "Please upgrade Node.js to 20 or newer: https://nodejs.org/"
    exit 1
} else {
    Write-Ok "Node.js version OK: $rawVersion"
}

# Ensure npm exists
$npmCmd = Get-Command npm -ErrorAction SilentlyContinue
if (-not $npmCmd) {
    Write-Err "npm not found. Please install a Node.js distribution that includes npm."
    exit 1
}

# ==========================================
# 2) Install Codex CLI
# ==========================================
Write-Host "`nStep 2/3: Installing Codex CLI (@openai/codex@latest)..."
try {
    # If global install hits permissions issues, run this script as Administrator.
    npm install -g @openai/codex@latest
    Write-Ok "Codex CLI installed/updated."
} catch {
    Write-Err "Codex CLI installation failed: $($_.Exception.Message)"
    Write-Host "If you see a permissions error, re-run this script as Administrator"
    Write-Host "or run the following manually:"
    Write-Host "  npm install -g @openai/codex@latest"
    exit 1
}

# ==========================================
# 3) Gather inputs and write config
# ==========================================
Write-Host "`nStep 3/3: Configure 4096bytes connection..."

# Domain (host only, without protocol)
$domain = ""
while ([string]::IsNullOrWhiteSpace($domain)) {
    $domain = Read-Host "Enter 4096bytes server domain (without https://, e.g., api.example.com)"
    if ($null -ne $domain) { $domain = $domain.Trim() }
    # Strip protocol and trailing slash if pasted
    if ($domain) {
        $domain = $domain -replace '^https?://', ''
        $domain = $domain.TrimEnd('/')
    }
}

# API key (plain input, like cr_xxx...)
$apiKey = ""
while ([string]::IsNullOrWhiteSpace($apiKey)) {
    $apiKey = Read-Host "Enter 4096bytes API Key (format: cr_xxxxxx...)"
    if ($null -ne $apiKey) { $apiKey = $apiKey.Trim() }
}

$configDir = Join-Path $HOME ".codex"
if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Force -Path $configDir | Out-Null
}

# Write config.toml
$configToml = @"
model_provider = "crs"
model = "gpt-5-codex"
model_reasoning_effort = "high"
network_access = "enabled"
disable_response_storage = true

[model_providers.crs]
name = "crs"
base_url = "https://$domain/openai"
wire_api = "responses"
requires_openai_auth = true
"@

Set-Content -LiteralPath (Join-Path $configDir "config.toml") -Value $configToml -Encoding utf8
Write-Ok "~/.codex/config.toml created."

# Write auth.json
$authJson = "{ `"OPENAI_API_KEY`": `"$apiKey`" }"
Set-Content -LiteralPath (Join-Path $configDir "auth.json") -Value $authJson -Encoding utf8
Write-Ok "~/.codex/auth.json created."

Write-Header "Done"
Write-Host "You can now run: codex" -ForegroundColor Gray
