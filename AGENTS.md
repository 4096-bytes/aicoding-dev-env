# Repository Guidelines

## Project Structure & Module Organization
- `ubuntu/`: Bash scripts for Ubuntu/WSL (e.g., `setup_ubuntu.sh`, `setup_codex_config.sh`).
- `macos/`: Bash scripts for macOS (`setup_mac.sh`, `setup_codex_config.sh`).
- `windows/`: PowerShell/batch for Windows (`setup_windows.ps1`, `install.bat`, `setup_codex_config.ps1`).
- Top-level docs: `README.md`, `README_EN.md`, `LICENSE`. No internal libraries or tests; this repo is script-centric.

## Build, Test, and Development Commands
- Run locally (Ubuntu/WSL): `bash ubuntu/setup_codex_config.sh` or `bash ubuntu/setup_ubuntu.sh`
- Run locally (macOS): `bash macos/setup_mac.sh` or `bash macos/setup_codex_config.sh`
- Run locally (Windows, as Admin): `powershell -ExecutionPolicy Bypass -File windows/setup_windows.ps1`
- Lint Bash: `shellcheck ubuntu/setup_ubuntu.sh` (and other `.sh` files)
- Lint PowerShell: `pwsh -c "Install-Module PSScriptAnalyzer -Scope CurrentUser -Force; Invoke-ScriptAnalyzer -Path windows -Recurse"`

## Coding Style & Naming Conventions
- Bash: `#!/bin/bash`, `set -e`; prefer 4-space indentation; functions use `lower_snake_case` (e.g., `print_step`).
- PowerShell: Verb-Noun naming (e.g., `Print-Header`), PascalCase parameters; set `$ErrorActionPreference = "Stop"`.
- Filenames: `setup_<os|purpose>.sh` and `setup_<purpose>.ps1`. Place files under the correct OS directory.
- Logging: Use existing helpers (`print_*` in Bash, `Print-*` in PS) and clear step banners.
- Line endings: `.sh` must use LF (enforced via `.gitattributes`); keep `.ps1` Windows-friendly.

## Localization & Encoding
- Scripts must not contain Chinese or other non-ASCII characters (code, comments, prompts, or logs). Use English-only to avoid encoding issues.
- Encoding: UTF-8 (no BOM). Keep strings ASCII-safe across shells.
- Quick check for violations: `rg -n '[^\\x00-\\x7F]' ubuntu macos windows`

## Testing Guidelines
- No unit tests; validate by running on target OS/WSL. Scripts must be idempotent (safe to run twice).
- Before/after change: capture key prompts and success banners. Include logs in PRs.
- Static checks: run ShellCheck/PSScriptAnalyzer and resolve warnings where practical.

## Commit & Pull Request Guidelines
- Commit style: follow Conventional Commits where possible, mirroring history (e.g., `feat(ubuntu): add Docker hint`, `fix(shell): enforce LF endings`, `refactor(windows): simplify WSL checks`).
- PRs must include: scope (OS and script paths), what changed and why, commands used for manual tests + outcomes, and any risk/rollback notes. Link issues when applicable.

## Security & Configuration Tips
- Never commit secrets. `~/.codex/config.toml` and `~/.codex/auth.json` are created at runtime—do not add to the repo.
- Request sudo early (`sudo -v`) and minimize repeated `sudo`. Prompt before destructive actions (e.g., unregister/migrate).
- Handle network checks gracefully; provide clear next steps when GitHub Raw is unreachable.
