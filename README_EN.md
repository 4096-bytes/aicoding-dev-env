[![Email](https://img.shields.io/badge/Email-x4096bytes%40gmail.com-red?logo=gmail&logoColor=white)](mailto:x4096bytes@gmail.com)
[![Telegram](https://img.shields.io/badge/Telegram-@x4096bytes-blue?logo=telegram&logoColor=white)](https://t.me/x4096bytes)

# AICoding Dev Environment

[🇨🇳 简体中文](README.md) | **[🇺🇸 English]**

------

**AI Coding Environment Automation Tool.**

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

https://github.com/user-attachments/assets/39717e9c-eba1-4c50-88c0-27c411c0a051

------

## 🌐 Network Note

Using Codex via 4096Bytes does not require a VPN. For better speed and stability, we recommend turning off your VPN/proxy while using it.

------

## 🚀 Plan A: Lightweight Config (Recommended)<a id="plan-a"></a>

**Target Audience:** Users with a basic development environment (at least Node.js installed) who only need to enable AI coding capabilities.

**Features:** Installs Codex CLI + Configures config.toml + Sets API Key.

### 💻 Windows Users

Run in PowerShell (no clone required):

```powershell
irm https://raw.githubusercontent.com/4096-bytes/aicoding-dev-env/main/windows/setup_codex_config.ps1 | iex
```

After completing this step: go to the section below, "IDE Plugin Integration", to install and configure the Codex extension for VS Code/Cursor (choose Use API Key to sign in).

### 🐧 Ubuntu / Linux / WSL Users

Run the following in your terminal:

```bash
curl -O https://raw.githubusercontent.com/4096-bytes/aicoding-dev-env/main/ubuntu/setup_codex_config.sh && bash setup_codex_config.sh
```

After completing this step: go to the section below, "IDE Plugin Integration", to install and configure the Codex extension for VS Code/Cursor (choose Use API Key to sign in).

### 🍎 macOS Users

Run the following in your terminal:

```bash
curl -O https://raw.githubusercontent.com/4096-bytes/aicoding-dev-env/main/macos/setup_codex_config.sh && bash setup_codex_config.sh
```

After completing this step: go to the section below, "IDE Plugin Integration", to install and configure the Codex extension for VS Code/Cursor (choose Use API Key to sign in).

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

## 🧩 IDE Plugin Integration<a id="ide-plugins"></a>

Want to use Codex directly inside your IDE? Install the official extension in VS Code or Cursor.

- VS Code Download: <https://code.visualstudio.com/Download>
- Cursor Download: <https://cursor.com>

Steps:

1) Open VS Code or Cursor and go to Extensions/Marketplace.
2) Search for and install the extension “Codex”. Make sure it is the official one from openai.com.
3) After installation, choose “Use API Key” in the extension’s sign-in options and enter your API key to start coding.

------

## 💎 Codex Group Access
For Codex group access or any questions, contact us:

📧 Email: [x4096bytes@gmail.com](mailto:x4096bytes@gmail.com)

✈️ Telegram: [@x4096bytes](https://t.me/x4096bytes)

------

Happy Coding! 🚀
