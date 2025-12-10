# 4096Bytes AICoding Dev Environment

[🇨🇳 简体中文](README.md) | **[🇺🇸 English]**

------

**4096Bytes Cross-Platform AI Coding Environment Automation Tool.**

This project provides two solutions:

1. **Quick Setup Script**: For users with an existing development environment who only need to install the AI toolchain.
2. **Full Stack Bootstrap Script**: For new machines, automatically sets up the OS, Shell, Docker, Runtime, and full infrastructure.

------

## 🚦 Choose Your Path

Please select the plan that best suits your current system status:

| **Your Status**                  | **Requirements**                                             | **Recommended Plan**                    |
| -------------------------------- | ------------------------------------------------------------ | --------------------------------------- |
| **Veteran / Environment Ready**  | Node.js/Git already installed; only need Codex & 4096Bytes connection | [🚀 Plan A: Lightweight Config](#plan-a) |
| **New PC / Missing Environment** | Nothing installed; need the full stack (Zsh, Docker, Java, Node, etc.) | [🏗️ Plan B: Build from Scratch](#plan-b) |

------

## ✨ Live Demo

⬇️ **Codex in Action:** Refactoring a basic login page into a **Glassmorphism** style in just minutes.

https://github.com/user-attachments/assets/f9b509fe-c994-4014-b0d1-70e3bf9b1a3e

------

## 🚀 Plan A: Lightweight Config (Recommended)<a id="plan-a"></a>

**Target Audience:** Users with a basic development environment (at least Node.js installed) who only need to enable AI coding capabilities.

**Features:** Installs Codex CLI + Configures config.toml + Sets API Key.

### 🐧 Ubuntu / Linux / WSL Users

Run the following in your terminal:

```bash
curl -O https://raw.githubusercontent.com/4096-bytes/aicoding-dev-env/main/ubuntu/setup_codex_config.sh && bash setup_codex_config.sh
```

### 🍎 macOS Users

Run the following in your terminal:

```bash
curl -O https://raw.githubusercontent.com/4096-bytes/aicoding-dev-env/main/macos/setup_codex_config.sh && bash setup_codex_config.sh
```

------

## 🏗️ Plan B: Build from Scratch (Full Stack)<a id="plan-b"></a>

**Target Audience:** Users setting up a new computer or those who want to completely reset their development environment.

**Features:** OS Optimization + Zsh Customization + Docker + Node(NVM) + Java/Maven (Optional) + AI Toolchain.

### 💻 Windows Users (Win10/11)

The script automatically handles WSL installation, image migration (C->D), and Ubuntu environment initialization.

1. **Right-click** the Start Menu and select **"Terminal (Admin)"** or **"PowerShell (Admin)"**.
2. Run the following command:

```powershell
irm https://raw.githubusercontent.com/4096-bytes/aicoding-dev-env/main/windows/setup_windows.ps1 | iex
```

### 🐧 Ubuntu Users (Native)

For native Ubuntu systems.

```bash
wget -O setup_ubuntu.sh https://raw.githubusercontent.com/4096-bytes/aicoding-dev-env/main/ubuntu/setup_ubuntu.sh && bash setup_ubuntu.sh
```

### 🍎 macOS Users (Intel/Apple Silicon)

Automatically installs Homebrew, Oh My Zsh, Docker Desktop, etc.

```bash
curl -O https://raw.githubusercontent.com/4096-bytes/aicoding-dev-env/main/macos/setup_mac.sh && bash setup_mac.sh
```

------

## 🛠️ Dev Tools Configuration (VS Code)

To get the best AI coding experience, we recommend **Visual Studio Code**.

1. **Install VS Code**: 
2. **Install Core Extensions**:
   - **WSL**: (Required for Windows users) Connects to the Ubuntu environment.
   - **Codex**: (Required) The 4096Bytes AI coding visualization client.

### ✨ Quick Start (Magic Move)

Once configured, enter the project directory in your terminal (Ubuntu/macOS) and type:

```bash
code .
```

The system will automatically launch the VS Code GUI, and you can start using the Codex extension immediately.

------

## ⚙️ Post-Installation (Manual Config)

If you used **Plan B (Build from Scratch)**, please note the following steps after the script finishes:

1. **Apply Configuration**:

   ```bash
   source ~/.zshrc  # 或 source ~/.bashrc
   ```

2. **Add Personal Info** (Infrastructure scripts do not contain private data):

   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "you@example.com"
   ```

3. **Maven Private Repo** (If the backend stack was installed):

   Copy your `settings.xml` to the corresponding Maven `conf` directory.

------

## 📂 Repository Structure

```
aicoding-dev-env/
├── windows/
│   ├── setup_windows.ps1
│   └── install.bat
├── ubuntu/
│   ├── setup_ubuntu.sh
│   └── setup_codex_config.sh
├── macos/
│   ├── setup_mac.sh
│   └── setup_codex_config.sh
└── README.md
```

## ❓ FAQ

**Q: How do Windows users use "Plan A"?**

A: Please enter your WSL (Ubuntu) terminal first, then run the Ubuntu version of the lightweight script inside WSL.

**Q: I get a 404 error when running the script?**

A: Please check if your network can access GitHub Raw content, or try enabling a VPN.

**Q: I already have Node.js installed. Will "Plan B" cause conflicts?**

A: The script checks your existing environment: if it finds NVM, it skips that step; if it finds a system-level Node, it prompts you to install NVM for management. The Codex CLI is installed within the NVM environment by default and will not conflict.

------

Happy Coding! 🚀

Powered by 4096Bytes Engineering Team

