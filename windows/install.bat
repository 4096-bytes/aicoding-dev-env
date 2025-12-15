@echo off
cd /d "%~dp0"
Title 4096Bytes Setup Launcher

:: ==============================================================
:: Launcher for setup_host.ps1
:: 1. Auto-requests Administrator privileges (UAC).
:: 2. Bypasses PowerShell Execution Policy restrictions.
:: ==============================================================

echo.
echo [INFO] Requesting Administrator privileges...
echo [INFO] A UAC window will pop up. Please click 'Yes'.
echo.

:: Launch PowerShell as Administrator
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dp0setup_windows.ps1""' -Verb RunAs}"

:: Optional: Close this launcher window immediately after spawning the PS process

exit
