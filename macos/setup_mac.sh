#!/bin/bash
# setup_mac.sh
# 4096Bytes AICoding Stack - macOS Environment Setup
# Features: Homebrew, Zsh, Node.js 22 (NVM), Docker Desktop, Codex CLI
# Idempotent: Can be run multiple times safely.

set -e

# --- Helper Functions ---
print_step() {
    echo -e "\n\033[1;36m========================================\033[0m"
    echo -e "\033[1;36mStep $1/8: $2\033[0m"
    echo -e "\033[1;36m========================================\033[0m"
}

print_warn() {
    echo -e "\033[1;33m[WARN] $1\033[0m"
}

print_success() {
    echo -e "\033[1;32m[OK] $1\033[0m"
}

print_info() {
    echo -e "\033[1;34m[INFO] $1\033[0m"
}

print_error() {
    echo -e "\033[1;31m[ERROR] $1\033[0m"
}

# Ask for sudo upfront (needed for some brew operations or permission fixes)
sudo -v

# ============================
# Step 1: Network Connectivity Check
# ============================
print_step 1 "Checking Network Connectivity"

echo ">>> Testing connection to github.com..."
if curl -s --connect-timeout 5 -I https://github.com > /dev/null; then
    print_success "Connection to GitHub is healthy."
else
    print_warn "Cannot reach GitHub."
    print_warn "Please check your network settings or VPN."
    read -p "Do you want to continue anyway? (y/N) " continue_choice
    if [[ ! "$continue_choice" =~ ^[Yy]$ ]]; then
        print_error "Aborted by user."
        exit 1
    fi
fi

# ============================
# Step 2: Install Homebrew (The Package Manager)
# ============================
print_step 2 "Checking Homebrew"

if ! command -v brew &> /dev/null; then
    echo ">>> Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Configure shell environment for Homebrew immediately
    if [[ $(uname -m) == 'arm64' ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    print_success "Homebrew installed."
else
    print_success "Homebrew is already installed."
fi

# ============================
# Step 3: System Base Tools
# ============================
print_step 3 "Base Tools (git, wget, unzip)"

echo ">>> Updating Homebrew..."
brew update

echo ">>> Installing tools..."
brew install git wget unzip curl
print_success "Base tools ready."

# ============================
# Step 4: Zsh & Oh My Zsh
# ============================
print_step 4 "Installing Zsh Environment"

# macOS defaults to Zsh, just need OMZ
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo ">>> Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    echo ">>> Installing Plugins..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions 2>/dev/null || true
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting 2>/dev/null || true
    
    # Idempotent config modification
    # Note: macOS sed requires empty string for backup extension
    if ! grep -q "zsh-autosuggestions" ~/.zshrc; then
        sed -i '' 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
    fi
    print_success "Zsh setup complete."
else
    print_success "Oh My Zsh is already installed. Skipping."
fi

# ============================
# Step 5: Backend Stack (Java 8 & Maven) - OPTIONAL
# ============================
print_step 5 "Backend Stack (Java 8 & Maven)"

read -p ">>> Do you want to install Java 8 and Maven 3.6.3? (y/N) " install_backend
if [[ "$install_backend" =~ ^[Yy]$ ]]; then
    echo ">>> Installing Backend Stack..."

    # 1. Java 8 via Homebrew
    # We use openjdk@8 which is keg-only, need to link it
    if ! brew list openjdk@8 &>/dev/null; then
        echo "   -> Installing OpenJDK 8..."
        brew install openjdk@8
        
        # Link to PATH in .zshrc
        if ! grep -q "openjdk@8" ~/.zshrc; then
            echo 'export PATH="/opt/homebrew/opt/openjdk@8/bin:$PATH"' >> ~/.zshrc
            echo 'export PATH="/usr/local/opt/openjdk@8/bin:$PATH"' >> ~/.zshrc # Fallback for Intel
        fi
        print_success "Java 8 installed."
    else
        print_success "Java 8 is already installed."
    fi

    # 2. Maven 3.6.3 (Download Binary for consistency)
    MAVEN_DIR="$HOME/apache-maven-3.6.3"
    
    if [ -d "$MAVEN_DIR" ]; then
        print_success "Maven 3.6.3 directory already exists ($MAVEN_DIR). Skipping."
    else
        echo "   -> Downloading Maven 3.6.3..."
        wget -q https://archive.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
        tar -zxvf apache-maven-3.6.3-bin.tar.gz -C "$HOME/" > /dev/null
        rm apache-maven-3.6.3-bin.tar.gz
        print_success "Maven installed to $MAVEN_DIR"
    fi
        
    # Add to .zshrc
    if ! grep -q "MAVEN_HOME" ~/.zshrc; then
        echo -e "\n# Java & Maven" >> ~/.zshrc
        echo "export MAVEN_HOME=$MAVEN_DIR" >> ~/.zshrc
        echo 'export PATH=$MAVEN_HOME/bin:$PATH' >> ~/.zshrc
        print_info "Added Maven to PATH in .zshrc"
    fi

else
    echo ">>> Skipping Backend Stack."
fi

# ============================
# Step 6: Docker Desktop - OPTIONAL
# ============================
print_step 6 "Docker Desktop"

read -p ">>> Do you want to install Docker Desktop? (y/N) " install_docker
if [[ "$install_docker" =~ ^[Yy]$ ]]; then
    if ! command -v docker &> /dev/null; then
        echo ">>> Installing Docker Desktop via Homebrew Cask..."
        brew install --cask docker
        print_success "Docker Desktop installed."
        print_info "Note: You must start 'Docker' from Applications manually to finish setup."
    else
        print_success "Docker is already installed."
    fi
else
    echo ">>> Skipping Docker."
fi

# ============================
# Step 7: Node.js & NVM
# ============================
print_step 7 "Node.js & NVM"

export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
    echo ">>> Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    print_success "NVM installed."
else
    print_success "NVM already installed."
fi

# Load NVM immediately
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node 22
if ! nvm list | grep -q "v22.20.0"; then
    echo ">>> Installing Node v22.20.0..."
    nvm install 22.20.0
    nvm alias default 22.20.0
    print_success "Node v22 installed."
else
    print_success "Node v22 is ready."
fi

print_info "Node Version Manager (NVM) Tip:"
print_info " -> To switch versions: 'nvm use 22.20.0' or 'nvm use system'"

# ============================
# Step 8: OpenAI Codex CLI & 4096Config
# ============================
print_step 8 "Codex CLI & Configuration"

echo ">>> Installing @openai/codex..."
npm install -g @openai/codex@latest

if command -v codex &> /dev/null; then
    print_success "Codex CLI installed."
else
    print_warn "Codex installed but not in PATH yet."
fi

# --- 4096Bytes Config ---
mkdir -p ~/.codex

# 8.1 Write config.toml
if [ -f "$HOME/.codex/config.toml" ]; then
    print_info "~/.codex/config.toml already exists. Skipping."
else
    echo ""
    echo "----------------------------------------------------"
    echo "Please enter the 4096bytes Server Domain."
    echo "----------------------------------------------------"
    
    TARGET_DOMAIN=""
    while [[ -z "$TARGET_DOMAIN" ]]; do
        read -p "Domain > " TARGET_DOMAIN
    done

    echo ">>> Writing ~/.codex/config.toml..."
    cat > ~/.codex/config.toml <<EOF
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
    print_success "Config created."
fi

# 8.2 Write auth.json
if [ -f "$HOME/.codex/auth.json" ]; then
    print_info "~/.codex/auth.json already exists. Skipping."
else
    echo '{ "OPENAI_API_KEY": null }' > ~/.codex/auth.json
    print_success "Auth file created."
fi

# 8.3 Environment Variable
if grep -q "CRS_OAI_KEY" ~/.zshrc; then
    print_info "API Key (CRS_OAI_KEY) already configured. Skipping."
else
    echo ""
    echo "----------------------------------------------------"
    echo "Please enter your 4096bytes API Key."
    echo "Format: starts with 'cr_xxxxxxxxxx'"
    echo "----------------------------------------------------"

    CRS_KEY=""
    while [[ -z "$CRS_KEY" ]]; do
        read -p "API Key > " CRS_KEY
    done

    echo "export CRS_OAI_KEY=$CRS_KEY" >> ~/.zshrc
    print_success "Added CRS_OAI_KEY to .zshrc."
fi

# ============================
# Finish
# ============================
echo -e "\n\033[1;32m========================================\033[0m"
echo -e "\033[1;32m🎉  All Done! macOS Environment is Ready.\033[0m"
echo -e "\033[1;32m========================================\033[0m"
echo "IMPORTANT: Please execute the following command MANUALLY:"
echo ""
echo -e "\033[1;33m    source ~/.zshrc\033[0m"
echo ""
echo -e "\033[1;36m🚀  Ready to Code!\033[0m"
if [[ "$install_docker" =~ ^[Yy]$ ]]; then
    echo "Note: Open 'Docker' from Applications to start the Docker Engine."
fi