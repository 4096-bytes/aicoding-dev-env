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
# 1. Check & Install Codex CLI
# ==========================================
echo -e "\n${CYAN}[1/4] Checking Codex CLI...${RESET}"

if command -v codex &> /dev/null; then
    echo -e "${GREEN}✓ Codex CLI is already installed.${RESET}"
else
    echo -e "${YELLOW}Codex CLI not found. Installing via npm...${RESET}"
    if command -v npm &> /dev/null; then
        # Try installing globally. If it fails due to permissions, warn user.
        if npm install -g @openai/codex@latest; then
            echo -e "${GREEN}✓ Codex CLI installed.${RESET}"
        else
            echo -e "${RED}[ERROR] Installation failed. You might need 'sudo'.${RESET}"
            echo "Try running: sudo npm install -g @openai/codex@latest"
            exit 1
        fi
    else
        echo -e "${RED}[ERROR] npm is not installed. Please install Node.js first.${RESET}"
        echo "Recommended: brew install node"
        exit 1
    fi
fi

# ==========================================
# 2. Gather Information (Domain & Key)
# ==========================================
echo -e "\n${CYAN}[2/4] Configuration Setup${RESET}"

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
echo -e "\n${CYAN}[3/4] Writing Configuration Files${RESET}"

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
disable_response_storage = true
preferred_auth_method = "apikey"

[model_providers.crs]
name = "crs"
base_url = "https://$TARGET_DOMAIN/openai"
wire_api = "responses"
requires_openai_auth = true
env_key = "CRS_OAI_KEY"
EOF
echo -e "${GREEN}✓ ~/.codex/config.toml updated.${RESET}"

# Write auth.json
# We overwrite this ensuring OPENAI_API_KEY is null
echo '{ "OPENAI_API_KEY": null }' > "$CONFIG_DIR/auth.json"
echo -e "${GREEN}✓ ~/.codex/auth.json updated (OPENAI_API_KEY set to null).${RESET}"

# ==========================================
# 4. Configure Environment Variable
# ==========================================
echo -e "\n${CYAN}[4/4] Setting Environment Variable${RESET}"

# Detect Shell (macOS usually defaults to zsh now)
SHELL_NAME=$(basename "$SHELL")
RC_FILE=""

if [ "$SHELL_NAME" = "zsh" ]; then
    RC_FILE="$HOME/.zshrc"
elif [ "$SHELL_NAME" = "bash" ]; then
    RC_FILE="$HOME/.bash_profile" # macOS uses .bash_profile for login shells
else
    echo -e "${YELLOW}Unknown shell ($SHELL_NAME). Defaulting to ~/.zshrc${RESET}"
    RC_FILE="$HOME/.zshrc"
fi

# Update RC File (Idempotent)
# Note: macOS sed requires an empty string argument '' for -i
if grep -q "CRS_OAI_KEY" "$RC_FILE"; then
    # Update existing key
    sed -i '' "s|export CRS_OAI_KEY=.*|export CRS_OAI_KEY=$CRS_KEY|" "$RC_FILE"
    echo -e "${GREEN}✓ Updated existing CRS_OAI_KEY in $RC_FILE${RESET}"
else
    # Append new key
    echo "" >> "$RC_FILE"
    echo "# 4096Bytes Codex Key" >> "$RC_FILE"
    echo "export CRS_OAI_KEY=$CRS_KEY" >> "$RC_FILE"
    echo -e "${GREEN}✓ Added CRS_OAI_KEY to $RC_FILE${RESET}"
fi

# ==========================================
# Finish
# ==========================================
echo -e "\n${GREEN}========================================${RESET}"
echo -e "${GREEN}🎉 Configuration Complete!${RESET}"
echo -e "${GREEN}========================================${RESET}"
echo "To apply the environment variable changes, please run:"
echo ""
echo -e "    ${YELLOW}source $RC_FILE${RESET}"
echo ""
echo "Then you can verify by running:"
echo "    codex"