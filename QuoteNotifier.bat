@echo off
REM ============================================================
REM  Quote Notifier - START
REM  Double-click this once. It starts a hidden background
REM  process that shows a quote notification every 6-7 hours.
REM
REM  It shows one notification immediately so you know it works.
REM  To stop it, double-click StopNotifier.bat
REM  Nothing is installed and no system settings are changed.
REM ============================================================

start "" /min powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0notifier.ps1"

echo Quote Notifier started. You will get a quote roughly every 6-7 hours.
echo (A test notification should appear in a few seconds.)
timeout /t 3 >nul
