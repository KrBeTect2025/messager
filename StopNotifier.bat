@echo off
REM ============================================================
REM  Quote Notifier - STOP
REM  Stops the background notifier process cleanly.
REM  It only kills the notifier process itself (using its PID
REM  file) - it never touches any Windows service or system file.
REM ============================================================

set "PIDFILE=%~dp0notifier.pid"

if not exist "%PIDFILE%" (
    echo Notifier is not running.
    timeout /t 2 >nul
    exit /b
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "$p = Get-Content '%PIDFILE%'; if ($p) { Stop-Process -Id $p -Force -ErrorAction SilentlyContinue }; Remove-Item '%PIDFILE%' -Force -ErrorAction SilentlyContinue"

echo Quote Notifier stopped.
timeout /t 2 >nul
