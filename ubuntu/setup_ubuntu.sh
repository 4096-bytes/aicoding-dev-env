#!/bin/bash
# setup_ubuntu.sh
# 4096Bytes AICoding Stack - Ubuntu Environment Setup
# Features: Network Check, Zsh, Docker, Node.js 22 (NVM), Codex CLI, 4096Bytes Config
# Idempotent: Can be run multiple times safely. Files will NOT be overwritten if they exist.

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

# Ask for sudo upfront
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
# Step 2: System Update & Base Tools
# ============================
print_step 2 "System Update & Base Tools"

echo ">>> Updating apt repositories..."
sudo apt update
echo ">>> Installing curl, git, wget, unzip, zsh..."
sudo apt install -y zsh curl git wget unzip
print_success "Base tools ready."

# ============================
# Step 3: Zsh & Oh My Zsh
# ============================
print_step 3 "Installing Zsh Environment"

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo ">>> Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    echo ">>> Installing Plugins..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions 2>/dev/null || true
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting 2>/dev/null || true
    
    # Idempotent config modification
    if ! grep -q "zsh-autosuggestions" ~/.zshrc; then
        sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
    fi
    print_success "Zsh setup complete."
else
    print_success "Oh My Zsh is already installed. Skipping."
fi

# ============================
# Step 4: Backend Stack (Java & Maven) - OPTIONAL
# ============================
print_step 4 "Backend Stack (Java 8 & Maven)"

# Check existing Java version
EXISTING_JAVA=""
if command -v java &> /dev/null; then
    EXISTING_JAVA=$(java -version 2>&1 | head -n 1)
    print_info "Detected existing Java: $EXISTING_JAVA"
fi

read -p ">>> Do you want to install Java 8 and Maven 3.6.3? (y/N) " install_backend
if [[ "$install_backend" =~ ^[Yy]$ ]]; then
    echo ">>> Installing Backend Stack..."

    # 1. Java 8
    if ! java -version 2>&1 | grep -q "1.8.0"; then
        echo "   -> Installing OpenJDK 8..."
        sudo apt install -y openjdk-8-jdk
        
        # Guide for multi-JDK environment
        if [ -n "$EXISTING_JAVA" ]; then
             print_warn "Multiple Java versions detected."
             print_info "To switch default Java version, run: sudo update-alternatives --config java"
        fi
    else
        print_success "Java 8 is already installed."
    fi

    # 2. Maven
    MAVEN_DIR="/opt/apache-maven-3.6.3"
    
    if [ -d "$MAVEN_DIR" ]; then
        print_success "Maven 3.6.3 directory already exists ($MAVEN_DIR). Skipping installation."
    else
        echo "   -> Downloading Maven 3.6.3..."
        wget -q https://archive.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
        sudo tar -zxvf apache-maven-3.6.3-bin.tar.gz -C /opt/ > /dev/null
        rm apache-maven-3.6.3-bin.tar.gz
        print_success "Maven installed to $MAVEN_DIR"
    fi
        
    # Idempotent env var addition
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
# Step 5: Docker Engine - OPTIONAL
# ============================
print_step 5 "Docker Engine"

read -p ">>> Do you want to install Docker Engine? (y/N) " install_docker
if [[ "$install_docker" =~ ^[Yy]$ ]]; then
    if ! command -v docker &> /dev/null; then
        echo ">>> Installing Docker..."
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        
        sudo usermod -aG docker $USER
        
        echo "   -> Enabling Docker to start on boot..."
        sudo systemctl enable --now docker
        
        print_success "Docker installed and started."
    else
        print_success "Docker is already installed."
    fi
else
    echo ">>> Skipping Docker."
fi

# ============================
# Step 6: Node.js & NVM
# ============================
print_step 6 "Node.js & NVM"

# Detect System Node
if command -v node &> /dev/null && [ ! -d "$HOME/.nvm" ]; then
    SYS_NODE_VER=$(node -v)
    print_warn "System Node ($SYS_NODE_VER) detected without NVM."
    echo "   It is recommended to install NVM to manage multiple versions."
fi

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
print_info " -> To list versions:   'nvm list'"

# ============================
# Step 7: OpenAI Codex CLI
# ============================
print_step 7 "OpenAI Codex CLI"

echo ">>> Installing @openai/codex..."
# Using NVM's npm, so no sudo needed
npm install -g @openai/codex@latest

if command -v codex &> /dev/null; then
    print_success "Codex CLI installed successfully."
else
    print_warn "Codex installed but not found in PATH yet. Please source .zshrc."
fi

# ============================
# Step 8: Configure Codex for 4096bytes
# ============================
print_step 8 "Configuring Codex (4096bytes)"

# 8.1 Create Directory
mkdir -p ~/.codex

# 8.2 Check and Write config.toml
if [ -f "$HOME/.codex/config.toml" ]; then
    print_info "~/.codex/config.toml already exists. Skipping overwrite."
else
    # Domain Configuration - MANDATORY INPUT
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
network_access = "enabled"
disable_response_storage = true


[model_providers.crs]
name = "crs"
base_url = "https://$TARGET_DOMAIN/openai"
wire_api = "responses"
requires_openai_auth = true
EOF
    print_success "Config created with domain: $TARGET_DOMAIN"
fi

# 8.3 Check and Write auth.json
if [ -f "$HOME/.codex/auth.json" ]; then
    print_info "~/.codex/auth.json already exists. Skipping overwrite."
else
    echo ""
    echo "----------------------------------------------------"
    echo "Please enter your 4096bytes API Key."
    echo "Format: starts with 'cr_xxxxxxxxxx'"
    echo "----------------------------------------------------"

    # Loop until a value is entered
    CRS_KEY=""
    while [[ -z "$CRS_KEY" ]]; do
        read -p "API Key > " CRS_KEY
    done

    echo ">>> Configuring Environment Variable..."
    
    echo ">>> Writing ~/.codex/auth.json..."
    echo "{ \"OPENAI_API_KEY\": \"$CRS_KEY\" }" > ~/.codex/auth.json
    print_success "Auth file created."
fi

# ============================
# Step 9: Set Default Shell
# ============================
print_step 9 "Setting Default Shell to Zsh"

CURRENT_SHELL=$(grep "^$USER:" /etc/passwd | cut -d: -f7)
TARGET_SHELL=$(which zsh)

if [ "$CURRENT_SHELL" != "$TARGET_SHELL" ]; then
    echo ">>> Changing default shell to Zsh..."
    sudo chsh -s "$TARGET_SHELL" "$USER"
    print_success "Default shell changed to Zsh."
else
    print_info "Zsh is already the default shell."
fi

# ============================
# Finish
# ============================
echo -e "\n\033[1;32m========================================\033[0m"
echo -e "\033[1;32m🎉  All Done! Ubuntu Environment is Ready.\033[0m"
echo -e "\033[1;32m========================================\033[0m"

echo "IMPORTANT: Your default shell is now Zsh."
echo "Please LOG OUT and LOG BACK IN to apply this change completely."
echo ""
echo "To start using Zsh immediately (without logging out), run:"
echo -e "\033[1;33m    zsh\033[0m"
echo ""

echo -e "\033[1;36m🚀  Ready to Code!\033[0m"
echo "Next Steps:"
echo "1. git clone <your-project-repo>"
echo "2. cd <project-directory>"
echo "3. Type 'codex' to start the AI agent."

echo ""
echo "Reminder - Manual Configurations:"
echo "1. Git Identity:      git config --global user.name \"Your Name\""
echo "                      git config --global user.email \"you@example.com\""
if [[ "$install_backend" =~ ^[Yy]$ ]]; then
    echo "2. Maven Repo:        Copy 'settings.xml' to /opt/apache-maven-3.6.3/conf/"
fi
