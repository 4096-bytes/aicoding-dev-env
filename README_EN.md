# 4096Bytes AICoding Dev Environment

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Ubuntu-lightgrey)](https://github.com/4096-bytes/aicoding-dev-env)

---

**[🇺🇸 English]** | [🇨🇳 简体中文](README.md)

**The exclusive cross-platform AI coding environment bootstrapper for the 4096Bytes team.**

This project aims to set up a standardized full-stack development environment with a single command, pre-installing the core AI coding toolchain. Whether you are on Windows or Ubuntu, you can have a "Ready-to-Code" workspace in minutes.

## ✨ Features

The script automates the configuration of the following technology stack:

- **OS Foundation**: Windows 11/10 WSL2 auto-installation, System drive migration (C -> D), Mirrored networking configuration.
- **Shell**: Zsh + Oh My Zsh + Auto-suggestions & Syntax-highlighting plugins.
- **Runtime**:
  - **Node.js**: Node v22 (LTS) via NVM.
  - **Java**: OpenJDK 8 (Optional).
  - **Maven**: Maven 3.6.3 (Optional).
- **Container**: Native Docker Engine installation + Systemd auto-start (Optional).
- **AI Toolchain**:
  - Pre-installed **OpenAI Codex CLI**.
  - Auto-configured **4096Bytes Private Connection** (`config.toml`).
  - Automatic API Key environment variable injection.

------

## 🚀 Quick Start

### 💻 Windows Users (Recommended)

For Windows 10 or Windows 11. The script handles WSL installation, drive migration, and Ubuntu bootstrapping automatically.

1. **Right-click** the Start menu and select **"Terminal (Admin)"** or **"PowerShell (Admin)"**.
2. Copy and run the following command:

PowerShell

```
irm https://raw.githubusercontent.com/4096-bytes/aicoding-dev-env/main/windows/setup_host.ps1 | iex
```

> **What the script does:**
>
> 1. Pre-checks environment (Permissions/Virtualization).
> 2. Installs WSL2 (Ubuntu).
> 3. Migrates Ubuntu to Drive D (Saves space on C).
> 4. Downloads the Ubuntu setup script automatically.
> 5. **After Reboot**: It guides you into Ubuntu to finish the configuration.

### 🐧 Ubuntu / Linux Users

For native Ubuntu systems or existing manual WSL installations.

1. Open your terminal.
2. Download and run the setup script:

Bash

```
wget -O setup_ubuntu.sh https://raw.githubusercontent.com/4096-bytes/aicoding-dev-env/main/ubuntu/setup_ubuntu.sh && bash setup_ubuntu.sh
```

------

## 🛠️ Dev Tools Configuration (VS Code Integration)

For the best developer experience, we strongly recommend using **Visual Studio Code** with WSL.

### 1. Install Editor

- Download VS Code: https://code.visualstudio.com/download

### 2. Install Key Extensions

Open VS Code, go to the Extensions view (Sidebar), and install:

- **WSL (Microsoft)**: **Required**. Allows you to edit and debug code running in Ubuntu directly from VS Code on Windows.
- **Codex (AI Coding)**: **Recommended**. Provides a visual AI coding interface.

### 3. How to Launch (Magic Move)

Once installed, you don't need to manually open VS Code to find files. Simply navigate to your project directory in the Ubuntu (WSL) terminal and type:

Bash

```
code .
```

This will launch the VS Code GUI on Windows, connected to your WSL environment. You can then use the Codex extension for AI-assisted coding directly in the GUI.

------

## ⚙️ Post-Installation

When the script prints `🎉 All Done!`, the underlying environment is ready.

### 1. Apply Changes

The script cannot force a refresh of the current shell session. Please manually run:

Bash

```
source ~/.zshrc
```

### 2. Personal Configuration

Following "Infrastructure as Code" principles, we do not touch your personal identity. Please configure manually:

- **Git Identity**:

  Bash

  ```
  git config --global user.name "Your Name"
  git config --global user.email "you@example.com"
  ```

- **Maven Settings** (If Backend Stack was installed): Copy your private `settings.xml` to `/opt/apache-maven-3.6.3/conf/`.

### 3. Start AI Coding (Ultimate Goal)

You now have AI coding capabilities powered by 4096Bytes.

1. Clone a project:

   Bash

   ```
   git clone <your-project-repo>
   cd <project-directory>
   ```

2. **Option A (CLI)**:

   Bash

   ```
   codex
   ```

3. **Option B (VS Code GUI)**:

   Bash

   ```
   code .
   # Then use the Codex extension in the sidebar
   ```

------

## 📂 Repository Structure

Plaintext

```
aicoding-dev-env/
├── windows/
│   ├── setup_windows.ps1      # Windows Host Bootstrapper (WSL Mgmt/Migration)
│   └── install.bat         # Offline Launcher (Auto-Admin elevation)
├── ubuntu/
│   └── setup_ubuntu.sh     # Ubuntu Setup Script (Zsh/Node/Docker/Codex)
└── README.md
```

## ❓ FAQ

**Q: Windows script says "Running scripts is disabled on this system".** A: Run `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` in Admin PowerShell, or simply use the `install.bat` launcher provided in the `windows/` directory.

**Q: Does this support macOS?** A: Currently focused on Windows (WSL) and Ubuntu. MacOS support is planned.

**Q: I already have Node.js, will this overwrite it?** A: The script checks your environment. If NVM is detected, it skips installation. If a system-level Node is detected, it recommends installing NVM for better version management. Codex CLI is installed within NVM to avoid polluting the system.

------

**Happy Coding! 🚀** *Powered by 4096Bytes Engineering Team*