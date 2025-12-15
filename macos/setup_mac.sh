#!/bin/bash
# setup_mac.sh
# 4096Bytes AICoding Stack - macOS Environment Setup
# Features: Network Check, Homebrew, Zsh, Node.js 22 (NVM), Codex CLI + Completion, 4096Bytes Config
# Manual Step: Docker (Optional)
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
# Step 2: System Update & Base Tools (Homebrew)
# ============================
print_step 2 "System Update & Base Tools"

# Check for Homebrew
if ! command -v brew &> /dev/null; then
    print_warn "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add brew to shell env for this script execution
    if [[ $(uname -m) == 'arm64' ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    print_success "Homebrew is already installed."
fi

echo ">>> Updating Homebrew..."
brew update

echo ">>> Installing base tools (git, wget, unzip, zsh)..."
brew install git wget unzip zsh
print_success "Base tools ready."

# ============================
# Step 3: Zsh & Oh My Zsh
# ============================
print_step 3 "Installing Zsh Environment"

# Ensure .zshrc exists
touch ~/.zshrc

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo ">>> Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    echo ">>> Installing Plugins..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions 2>/dev/null || true
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting 2>/dev/null || true
    
    # Idempotent config modification (macOS sed requires empty string for -i)
    if ! grep -q "zsh-autosuggestions" ~/.zshrc; then
        sed -i '' 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
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

    # 1. Java 8 (via Homebrew)
    # Check if openjdk@8 is installed via brew
    if ! brew list openjdk@8 &>/dev/null; then
        echo "   -> Installing OpenJDK 8..."
        brew install openjdk@8
        
        # Link it so system java wrapper finds it
        echo "   -> Linking Java 8..."
        sudo ln -sfn "$(brew --prefix openjdk@8)/libexec/openjdk.jdk" /Library/Java/JavaVirtualMachines/openjdk-8.jdk
        
        if [ -n "$EXISTING_JAVA" ]; then
             print_warn "Multiple Java versions detected."
             print_info "To switch Java versions on macOS, consider using '/usr/libexec/java_home'."
        fi
    else
        print_success "OpenJDK 8 (Brew) is already installed."
    fi
    
    # Ensure JAVA_HOME is set in .zshrc if not present
    if ! grep -q "export JAVA_HOME" ~/.zshrc; then
        echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)' >> ~/.zshrc
    fi

    # 2. Maven
    MAVEN_DIR="/opt/apache-maven-3.6.3"
    
    if [ -d "$MAVEN_DIR" ]; then
        print_success "Maven 3.6.3 directory already exists ($MAVEN_DIR). Skipping."
    else
        echo "   -> Downloading Maven 3.6.3..."
        # Ensure /opt exists on macOS
        if [ ! -d "/opt" ]; then sudo mkdir -p /opt; fi
        
        wget -q https://archive.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
        sudo tar -zxvf apache-maven-3.6.3-bin.tar.gz -C /opt/ > /dev/null
        rm apache-maven-3.6.3-bin.tar.gz
        print_success "Maven installed to $MAVEN_DIR"
    fi
        
    # Idempotent env var addition to .zshrc
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
# Step 5: Node.js & NVM
# ============================
print_step 5 "Node.js & NVM"

export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
    echo ">>> Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    print_success "NVM installed."
else
    print_success "NVM already installed."
fi

# Load NVM for current session
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Configure NVM for Zsh
if ! grep -q 'export NVM_DIR="$HOME/.nvm"' ~/.zshrc; then
    echo ">>> Writing NVM config to .zshrc..."
    cat <<EOT >> ~/.zshrc

# NVM Configuration
export NVM_DIR="\$HOME/.nvm"
[ -s "\$NVM_DIR/nvm.sh" ] && \\. "\$NVM_DIR/nvm.sh"
[ -s "\$NVM_DIR/bash_completion" ] && \\. "\$NVM_DIR/bash_completion"
EOT
fi

# Install Node 22
if ! nvm list | grep -q "v22.20.0"; then
    echo ">>> Installing Node v22.20.0..."
    nvm install 22.20.0
    nvm alias default 22.20.0
    print_success "Node v22 installed."
else
    print_success "Node v22 is ready."
fi

# ============================
# Step 6: OpenAI Codex CLI & Completion
# ============================
print_step 6 "OpenAI Codex CLI & Completion"

echo ">>> Installing @openai/codex..."
npm install -g @openai/codex@latest

if command -v codex &> /dev/null; then
    print_success "Codex CLI installed."
else
    print_warn "Codex installed (wait for shell restart to recognize)."
fi

# Codex Completion for Zsh
echo ">>> Adding Codex auto-completion to .zshrc..."
if ! grep -q "codex completion zsh" ~/.zshrc; then
    echo -e "\n# Codex Completion" >> ~/.zshrc
    echo 'eval "$(codex completion zsh)"' >> ~/.zshrc
    print_success "Completion script added."
else
    print_info "Completion script already in .zshrc."
fi

# ============================
# Step 7: Configure Codex
# ============================
print_step 7 "Configuring Codex (4096bytes)"

mkdir -p ~/.codex

# 7.1 Config.toml
if [ -f "$HOME/.codex/config.toml" ]; then
    print_info "config.toml exists. Skipping."
else
    echo "----------------------------------------------------"
    echo "Please enter the 4096bytes Server Domain."
    echo "----------------------------------------------------"
    
    TARGET_DOMAIN=""
    while [[ -z "$TARGET_DOMAIN" ]]; do
        read -p "Domain > " TARGET_DOMAIN
    done

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
    print_success "Config saved."
fi

# 7.2 Auth.json
if [ -f "$HOME/.codex/auth.json" ]; then
    print_info "auth.json exists. Skipping."
else
    echo "----------------------------------------------------"
    echo "Please enter your 4096bytes API Key (cr_...)."
    echo "----------------------------------------------------"

    CRS_KEY=""
    while [[ -z "$CRS_KEY" ]]; do
        read -p "API Key > " CRS_KEY
    done

    echo "{ \"OPENAI_API_KEY\": \"$CRS_KEY\" }" > ~/.codex/auth.json
    print_success "Auth saved."
fi

# ============================
# Step 8: Set Default Shell
# ============================
print_step 8 "Setting Default Shell to Zsh"

CURRENT_SHELL=$(dscl . -read /Users/$USER UserShell | awk '{print $2}')
# Check if current shell ends with zsh
if [[ "$CURRENT_SHELL" != *"/zsh" ]]; then
    echo ">>> Changing default shell to Zsh..."
    # macOS usually has zsh at /bin/zsh
    chsh -s /bin/zsh
    print_success "Default shell changed to Zsh."
else
    print_info "Zsh is already default."
fi

# ============================
# Finish
# ============================
echo -e "\n\033[1;32m========================================\033[0m"
echo -e "\033[1;32m🎉  All Done! macOS Environment is Ready.\033[0m"
echo -e "\033[1;32m========================================\033[0m"

echo "IMPORTANT: Please LOG OUT and LOG BACK IN (or restart Terminal) to apply changes."
echo ""
echo "To start immediately, run:"
echo -e "\033[1;33m    zsh\033[0m"
echo ""

echo -e "\033[1;36m🚀  Ready to Code!\033[0m"
echo "Next Steps:"
echo "1. git clone <your-project-repo>"
echo "2. Type 'codex' to start the AI agent."

echo -e "\033[1;36m💡  Reminder - Manual Configurations Needed:\033[0m"
echo "1. Git Identity:      git config --global user.name \"Your Name\""
echo "                      git config --global user.email \"you@example.com\""
echo "2. Git Credential:    git config --global credential.helper osxkeychain"
echo "                      (Stores password safely in Keychain)"
echo "3. Docker (Optional): Install Docker Desktop for Mac:"
echo "                      https://docs.docker.com/desktop/install/mac-install/"
if [[ "$install_backend" =~ ^[Yy]$ ]]; then
    echo "4. Maven Repo:        Copy your 'settings.xml' to /opt/apache-maven-3.6.3/conf/"
fi
