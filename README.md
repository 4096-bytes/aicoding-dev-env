[![Email](https://img.shields.io/badge/Email-x4096bytes%40gmail.com-red?logo=gmail&logoColor=white)](mailto:x4096bytes@gmail.com)
[![Telegram](https://img.shields.io/badge/Telegram-@x4096bytes-blue?logo=telegram&logoColor=white)](https://t.me/x4096bytes)

# AICoding Dev Environment

**[🇨🇳 简体中文]** | [🇺🇸 English](README_EN.md) 

------

**AI 编程环境自动化引导工具。**

本项目提供两套方案：

1. **快速配置脚本**：面向已有开发环境的用户，仅安装 AI 工具链。
2. **全栈引导脚本**：面向新机用户，一键拉起 OS、Shell、Docker、Runtime 等全套基础设施。

------

## 🚦 选择你的安装路径

请根据您当前的系统状态选择最适合的方案：

| **你的状态**            | **需求**                                             | **推荐方案**                        |
| ----------------------- | ---------------------------------------------------- | ----------------------------------- |
| **老司机 / 环境已就绪** | 已安装 Node.js/Git，只想配置 Codex 和 4096Bytes 连接 | [**🚀 方案 A：轻量级配置**](#plan-a) |
| **新电脑 / 补齐环境**   | 什么都没装，需要 Zsh, Docker, Java, Node 等全家桶    | **[🏗️ 方案 B：从零搭建](#plan-b)**   |

------

## ✨ 效果演示 (Live Demo)

⬇️ **Codex 实战展示：** 快速将一个普通的登录页面重构为 **Glassmorphism (玻璃拟态)** 风格。

https://github.com/user-attachments/assets/39717e9c-eba1-4c50-88c0-27c411c0a051

------

## 🚀 方案 A：轻量级配置 (推荐)<a id="plan-a"></a>

适用人群：已有基础开发环境（至少已安装 Node.js），仅需接入 AI 编程能力的用户。

功能：安装 Codex CLI + 配置 config.toml + 设置 API Key。

### 💻 Windows 用户

在 PowerShell 运行（无需克隆仓库）：

```powershell
irm https://raw.githubusercontent.com/4096-bytes/aicoding-dev-env/main/windows/setup_codex_config.ps1 | iex
```

### 🐧 Ubuntu / Linux / WSL 用户

在终端运行：

```bash
curl -O https://raw.githubusercontent.com/4096-bytes/aicoding-dev-env/main/ubuntu/setup_codex_config.sh && bash setup_codex_config.sh
```

### 🍎 macOS 用户

在终端运行：

```bash
curl -O https://raw.githubusercontent.com/4096-bytes/aicoding-dev-env/main/macos/setup_codex_config.sh && bash setup_codex_config.sh
```

------

## 🏗️ 方案 B：从零搭建 (全栈环境)<a id="plan-b"></a>

适用人群：拿到新电脑，或者希望彻底重置开发环境的用户。

功能：OS优化 + Zsh美化 + Docker + Node(NVM) + Java/Maven(可选) + AI工具链。

### 💻 Windows 用户 (Win10/11)

脚本将全自动处理 WSL 安装、镜像迁移 (C->D) 和 Ubuntu 环境初始化。

1. **右键点击**开始菜单，选择 **"终端 (管理员)"** 或 **"PowerShell (管理员)"**。
2. 运行以下命令：

```powershell
irm https://raw.githubusercontent.com/4096-bytes/aicoding-dev-env/main/windows/setup_windows.ps1 | iex
```

### 🐧 Ubuntu 用户 (Native)

适用于原生 Ubuntu 系统。

```bash
wget -O setup_ubuntu.sh https://raw.githubusercontent.com/4096-bytes/aicoding-dev-env/main/ubuntu/setup_ubuntu.sh && bash setup_ubuntu.sh
```

### 🍎 macOS 用户 (Intel/Apple Silicon)

自动安装 Homebrew, Oh My Zsh, Docker Desktop 等。

```bash
curl -O https://raw.githubusercontent.com/4096-bytes/aicoding-dev-env/main/macos/setup_mac.sh && bash setup_mac.sh
```

------

## 💎 Codex 精品小车拼车
如需 Codex 拼车或有任何疑问，请联系我们：

📧 Email: [x4096bytes@gmail.com](mailto:x4096bytes@gmail.com)

✈️ Telegram: [@x4096bytes](https://t.me/x4096bytes)

------

Happy Coding! 🚀

