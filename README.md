# 4096Bytes AICoding Dev Environment

**[🇨🇳 简体中文]** | [🇺🇸 English](README_EN.md) 

------

**4096Bytes 跨平台 AI 编程环境自动化引导工具。**

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

## 🛠️ 开发工具配置 (VS Code)

为了获得最佳的 AI 编程体验，我们推荐 **Visual Studio Code**。

1. **安装 VS Code**: [官网下载](https://code.visualstudio.com/download)
2. **安装核心插件**:
   - **WSL**: (Windows 用户必装) 用于连接 Ubuntu 环境。
   - **Codex**: (必装) 4096Bytes AI 编程可视化客户端。

### ✨ 极速启动 (Magic Move)

配置完成后，在终端（Ubuntu/macOS）进入项目目录，直接输入：

```bash
code .
```

系统会自动拉起 VS Code GUI，你即可开始使用 Codex 插件进行 AI 编程。

------

## ⚙️ 后置操作 (Manual Config)

如果你使用的是 **方案 B (从零搭建)**，脚本结束后请留意：

1. **生效配置**:

   ```bash
   source ~/.zshrc  # 或 source ~/.bashrc
   ```
   
2. **补充个人信息** (基础设施脚本不包含个人隐私):

   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "you@example.com"
   ```
   
3. Maven 私服 (如果安装了后端栈):

   将 settings.xml 复制到对应的 Maven conf 目录下。

------

## 📂 仓库结构

```
aicoding-dev-env/
├── windows/
│   ├── setup_windows.ps1      # Windows 宿主引导 (WSL安装/迁移)
│   └── install.bat         # 离线启动器
├── ubuntu/
│   ├── setup_ubuntu.sh     # Ubuntu 全量安装脚本
│   └── setup_codex_config.sh # Ubuntu/WSL 轻量配置脚本
├── macos/
│   ├── setup_mac.sh        # macOS 全量安装脚本 (Homebrew等)
│   └── setup_codex_config.sh # macOS 轻量配置脚本
└── README.md
```

## ❓ 常见问题 (FAQ)

Q: Windows 用户如何使用“方案 A”？

A: 请先进入你的 WSL (Ubuntu) 终端，然后在 WSL 内部运行 Ubuntu 版本的轻量级脚本。

Q: 运行脚本时提示 404？

A: 请检查你的网络是否能正常访问 GitHub Raw 内容，或尝试开启 VPN。

Q: 我已有 Node.js，运行“方案 B”会冲突吗？

A: 它会检测现有环境：如果发现 NVM 会跳过；如果发现系统级 Node，会提示你安装 NVM 纳管。Codex CLI 默认安装在 NVM 环境中，互不影响。

------

Happy Coding! 🚀

Powered by 4096Bytes Engineering Team


