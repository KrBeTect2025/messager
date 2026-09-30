# ============================================================
#  Quote Notifier - shows a motivational quote as a Windows
#  toast notification every 6-7 hours.
#
#  Safe by design:
#    - No admin rights required
#    - No registry / scheduled task / system changes
#    - Runs as an ordinary user process; stop it any time
#      with StopNotifier.bat
# ============================================================

param(
    [switch]$Test   # -Test : show one notification right now and exit
)

$ErrorActionPreference = 'SilentlyContinue'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$pidFile   = Join-Path $scriptDir 'notifier.pid'

# ---------- single instance guard ----------
# If a notifier is already running, do nothing (prevents duplicates).
if (Test-Path $pidFile) {
    $oldPid = Get-Content $pidFile -ErrorAction SilentlyContinue
    if ($oldPid -and (Get-Process -Id $oldPid -ErrorAction SilentlyContinue)) {
        exit
    }
}

# ---------- load quotes ----------
$quotesFile = Join-Path $scriptDir 'quotes.txt'
$quotes = @()
if (Test-Path $quotesFile) {
    $quotes = Get-Content $quotesFile -Encoding UTF8 |
              Where-Object { $_.Trim() -ne '' }
}
if (-not $quotes -or $quotes.Count -eq 0) {
    $quotes = @(
        'The best way to get started is to quit talking and begin doing. - Walt Disney',
        'It always seems impossible until it is done. - Nelson Mandela',
        'Do what you can, with what you have, where you are. - Theodore Roosevelt',
        'Success is not final, failure is not fatal: it is the courage to continue that counts. - Winston Churchill',
        'Believe you can and you are halfway there. - Theodore Roosevelt',
        'Your time is limited, so do not waste it living someone else''s life. - Steve Jobs',
        'The future belongs to those who believe in the beauty of their dreams. - Eleanor Roosevelt',
        'Hardships often prepare ordinary people for an extraordinary destiny. - C.S. Lewis',
        'Start where you are. Use what you have. Do what you can. - Arthur Ashe',
        'Great things never come from comfort zones.'
    )
}

# ---------- Windows toast notification (built-in WinRT API) ----------
[void][Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
[void][Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]

# Use PowerShell's own registered AppUserModelID so toasts display
# without installing or registering anything new.
$appId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'

function Show-Quote {
    param([string]$Quote)

    # XML-escape the quote so special characters are safe
    $safe = [System.Security.SecurityElement]::Escape($Quote)
    $xmlText = "<toast duration=""long""><visual><binding template=""ToastGeneric"">" +
               "<text>Quick Motivation</text><text>$safe</text></binding></visual></toast>"

    $doc = New-Object Windows.Data.Xml.Dom.XmlDocument
    $doc.LoadXml($xmlText)
    $toast = New-Object Windows.UI.Notifications.ToastNotification($doc)
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId).Show($toast)
}

# ---------- test mode: one notification, then exit ----------
if ($Test) {
    Show-Quote -Quote (Get-Random -InputObject $quotes)
    exit
}

# ---------- normal run ----------
$PID | Set-Content -Path $pidFile -Encoding ASCII

# Show one immediately when started, so you know it works
Show-Quote -Quote (Get-Random -InputObject $quotes)

# Loop forever: sleep a random 6-7 hours, then show the next quote
while ($true) {
    $seconds = Get-Random -Minimum 21600 -Maximum 25200   # 6h - 7h
    Start-Sleep -Seconds $seconds
    Show-Quote -Quote (Get-Random -InputObject $quotes)
}
