#!/bin/bash
# setup_codex_config.sh (macOS)
# 4096Bytes - Codex Configuration Utility for Mac
# Target: Users with existing Node.js environment

set -e

# --- Colors ---
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
RED="\033[1;31m"
RESET="\033[0m"

echo -e "${CYAN}>>> 4096Bytes Codex Configuration Utility (macOS)${RESET}"

# ==========================================
# 0. Pre-flight Check: Node.js Version
# ==========================================
echo -e "\n${CYAN}[1/4] Checking Node.js Environment...${RESET}"

if ! command -v node &> /dev/null; then
    echo -e "${RED}[ERROR] Node.js is not installed.${RESET}"
    echo "Please install Node.js (Version > 20) first."
    echo "Recommended: brew install node"
    exit 1
fi

# Extract Major Version (e.g., v22.3.0 -> 22)
NODE_VER=$(node -v)
NODE_MAJOR=$(echo "$NODE_VER" | cut -d'.' -f1 | tr -d 'v')

echo -e "Detected Node.js version: ${YELLOW}$NODE_VER${RESET}"

# Check if version is greater than 20 ( > 20 )
if [ "$NODE_MAJOR" -le 20 ]; then
    echo -e "${RED}[ERROR] Node.js version must be greater than 20.${RESET}"
    echo -e "Current version is ${YELLOW}$NODE_MAJOR${RESET}, but > 20 is required."
    echo "Please upgrade Node.js and try again."
    exit 1
else
    echo -e "${GREEN}✓ Node.js version check passed ($NODE_VER).${RESET}"
fi

# ==========================================
# 1. Check & Install Codex CLI
# ==========================================
echo -e "\n${CYAN}[2/4] Checking Codex CLI...${RESET}"

if command -v codex &> /dev/null; then
    echo -e "${GREEN}✓ Codex CLI is already installed.${RESET}"
else
    echo -e "${YELLOW}Codex CLI not found. Installing via npm...${RESET}"
    
    # Try installing globally
    if npm install -g @openai/codex@latest; then
        echo -e "${GREEN}✓ Codex CLI installed.${RESET}"
    else
        echo -e "${RED}[ERROR] Installation failed. You might need 'sudo'.${RESET}"
        echo -e "${YELLOW}Attempting to install with sudo...${RESET}"
        if sudo npm install -g @openai/codex@latest; then
             echo -e "${GREEN}✓ Codex CLI installed (with sudo).${RESET}"
        else
             echo -e "${RED}[FATAL] Could not install Codex CLI.${RESET}"
             exit 1
        fi
    fi
fi

# ==========================================
# 2. Gather Information (Domain & Key)
# ==========================================
echo -e "\n${CYAN}[3/4] Configuration Setup${RESET}"

# Domain Input
echo "Please enter the 4096bytes Server Domain."
TARGET_DOMAIN=""
while [[ -z "$TARGET_DOMAIN" ]]; do
    read -p "Domain > " TARGET_DOMAIN
done

# API Key Input
echo -e "\nPlease enter your 4096bytes API Key."
echo -e "Format: starts with ${YELLOW}cr_xxxxxxxxxx${RESET}"
CRS_KEY=""
while [[ -z "$CRS_KEY" ]]; do
    read -p "API Key > " CRS_KEY
done

# ==========================================
# 3. Write Config Files
# ==========================================
echo -e "\n${CYAN}[4/4] Writing Configuration Files${RESET}"

CONFIG_DIR="$HOME/.codex"
mkdir -p "$CONFIG_DIR"

# Backup existing config if exists
if [ -f "$CONFIG_DIR/config.toml" ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    mv "$CONFIG_DIR/config.toml" "$CONFIG_DIR/config.toml.bak_$TIMESTAMP"
    echo -e "${YELLOW}Backed up existing config.toml to config.toml.bak_$TIMESTAMP${RESET}"
fi

# Write config.toml
cat > "$CONFIG_DIR/config.toml" <<EOF
model_provider = "crs"
model = "gpt-5-codex"
model_reasoning_effort = "high"
network_access = "enabled"
disable_response_storage = true

[model_providers.crs]
name = "crs"
base_url = "https://$TARGET_DOMAIN/openai"
wire_api = "responses"
requires_openai_auth = true
EOF
echo -e "${GREEN}✓ ~/.codex/config.toml updated.${RESET}"

# Write auth.json
echo "{ \"OPENAI_API_KEY\": \"$CRS_KEY\" }" > "$CONFIG_DIR/auth.json"
echo -e "${GREEN}✓ ~/.codex/auth.json updated.${RESET}"

# ==========================================
# Finish
# ==========================================
echo -e "\n${GREEN}========================================${RESET}"
echo -e "${GREEN}🎉 Configuration Complete!${RESET}"
echo -e "${GREEN}========================================${RESET}"
echo ""
echo -e "${YELLOW}!!! IMPORTANT ACTION REQUIRED !!!${RESET}"
echo -e "To ensure the 'codex' command works correctly, please:"
echo -e "1. ${CYAN}Restart your terminal${RESET} (Close and open a new window)"
echo -e "   OR run: ${CYAN}hash -r${RESET} (to refresh command cache)"
echo ""
echo "Then verification by running:"
echo -e "   ${GREEN}codex${RESET}"
echo ""
