# 4096Bytes AICoding Dev Environment

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Ubuntu-lightgrey)](https://github.com/4096-bytes/aicoding-dev-env)

[us English](README_EN.md) | **[🇨🇳 简体中文]**

---

**4096Bytes 团队专属的跨平台 AI 编程环境自动化引导工具。**

本项目旨在通过一行命令，自动化搭建标准化的全栈开发环境，并预装 AI 编程核心工具链。无论你是 Windows 还是 Ubuntu 用户，都能在几分钟内准备好 Ready-to-Code 的工作台。

## ✨ 核心功能 (Features)

该脚本将自动配置以下技术栈：

- **OS 基础**: Windows 11/10 WSL2 自动安装、系统盘迁移 (C -> D)、网络镜像配置。
- **Shell**: Zsh + Oh My Zsh + 自动补全/高亮插件 (颜值与效率并存)。
- **Runtime**:
  - **Node.js**: 通过 NVM 安装 Node v22 (LTS)。
  - **Java**: OpenJDK 8 (可选)。
  - **Maven**: Maven 3.6.3 (可选)。
- **Container**: Docker Engine 原生安装 + Systemd 自启动配置 (可选)。
- **AI Toolchain**:
  - 预装 **OpenAI Codex CLI**。
  - 自动配置 **4096Bytes 私有连接** (`config.toml`)。
  - 自动注入 API Key 环境变量。

------

## 🚀 极速安装 (Quick Start)

### 💻 Windows 用户 (推荐)

适用于 Windows 10 或 Windows 11 用户。脚本将全自动处理 WSL 安装、镜像迁移和 Ubuntu 环境配置。

1. **右键点击**开始菜单，选择 **"终端 (管理员)"** 或 **"PowerShell (管理员)"**。
2. 复制并运行以下命令：

PowerShell

```
irm https://raw.githubusercontent.com/4096-bytes/aicoding-dev-env/main/windows/setup_host.ps1 | iex
```

> **脚本执行流程：**
>
> 1. 环境预检 (权限/虚拟化)。
> 2. 安装 WSL2 (Ubuntu)。
> 3. 将 Ubuntu 迁移至 D 盘 (节省 C 盘空间)。
> 4. 自动下载 Ubuntu 初始化脚本。
> 5. **重启后**，脚本会自动引导你进入 Ubuntu 完成剩余配置。

### 🐧 Ubuntu / Linux 用户

适用于原生 Ubuntu 系统，或已手动安装 WSL 的用户。

1. 打开终端。
2. 运行以下命令下载并执行脚本：

Bash

```
wget -O setup_ubuntu.sh https://raw.githubusercontent.com/4096-bytes/aicoding-dev-env/main/ubuntu/setup_ubuntu.sh && bash setup_ubuntu.sh
```

------

## 🛠️ 开发工具配置 (VS Code Integration)

为了获得最佳的开发体验，我们强烈推荐使用 **Visual Studio Code** 配合 WSL 工作。

### 1. 安装编辑器

- 下载并安装 VS Code: https://code.visualstudio.com/download

### 2. 安装关键插件

打开 VS Code，点击左侧扩展图标 (Extensions)，搜索并安装以下插件：

- **WSL (Microsoft)**: 必装。它允许你在 Windows 上的 VS Code 中直接编辑和调试运行在 Ubuntu 中的代码。
- **Codex (AI Coding)**: 推荐。提供可视化的 AI 编程交互界面，比纯命令行更直观。

### 3. 如何启动 (Magic Move)

安装完上述插件后，你不再需要手动打开 VS Code 查找文件。 只需在 Ubuntu (WSL) 终端中进入你的项目目录，输入：

Bash

```
code .
```

系统会自动拉起 Windows 端的 VS Code GUI，并连接到当前的 WSL 环境。你可以在图形界面中通过 Codex 插件直接进行 AI 辅助编程。

------

## ⚙️ 环境初始化 (Post-Installation)

当脚本显示 `🎉 All Done!` 时，说明底层环境已准备就绪。

### 1. 验证环境与生效配置

脚本无法强制刷新当前 Shell，请务必手动执行一次：

Bash

```
source ~/.zshrc
```

### 2. 补充个人配置

脚本遵循“基础设施即代码”原则，不会触碰您的私人身份信息。请手动执行：

- **配置 Git 身份**：

  Bash

  ```
  git config --global user.name "你的名字"
  git config --global user.email "你的邮箱@example.com"
  ```

- **配置 Maven 私服** (如果安装了后端栈)： 将你的 `settings.xml` 复制到 `/opt/apache-maven-3.6.3/conf/` 目录下。

### 3. 开始 AI 编程 (Ultimate Goal)

现在的你已经拥有了接入 4096Bytes 算力的 AI 编程能力。

1. 拉取任意项目代码：

   Bash

   ```
   git clone <your-project-repo>
   cd <project-directory>
   ```

2. **启动方式 A (命令行)**：

   Bash

   ```
   codex
   ```

3. **启动方式 B (VS Code GUI)**：

   Bash

   ```
   code .
   # 然后在编辑器侧边栏使用 Codex 插件
   ```

------

## 📂 仓库结构

Plaintext

```
aicoding-dev-env/
├── windows/
│   ├── setup_windows.ps1      # Windows 宿主机引导脚本 (WSL管理/迁移)
│   └── install.bat         # 离线安装启动器 (自动提权)
├── ubuntu/
│   └── setup_ubuntu.sh     # Ubuntu 环境配置脚本 (Zsh/Node/Docker/Codex)
└── README.md
```

## ❓ 常见问题 (FAQ)

**Q: Windows 脚本执行时提示“禁止运行脚本”怎么办？** A: 请在管理员 PowerShell 中先执行 `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`，或者直接使用我们在 `windows/` 目录下提供的 `install.bat` 启动器。

**Q: 脚本支持 MacOS 吗？** A: 目前专注于 Windows (WSL) 和 Ubuntu。MacOS 支持正在计划中。

**Q: 我已有 Node.js 环境，脚本会覆盖吗？** A: 脚本会检测现有环境。如果检测到 NVM，会跳过安装；如果检测到系统级 Node，会提示你安装 NVM 以便更好地管理版本。Codex CLI 将安装在 NVM 环境下，不污染系统。

------

**Happy Coding! 🚀** *Powered by 4096Bytes Engineering Team*