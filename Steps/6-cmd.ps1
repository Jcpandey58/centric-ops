$RootFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
$logsPath = Join-Path $RootFolder "Logs"
$cmdLog = Join-Path $logsPath "ExposeUrl.log"

function Write-Log {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File $cmdLog -Append
}

# keytool command execution
$keytoolFolder = "C:\Program Files\Centric Software\C8\Wildfly\standalone\configuration\pkcs_stores"
$keytoolCommand = "keytool -list -keystore C8.pfx -storetype pkcs12 -storepass CSIWildCard#1"

$RunkeytoolCmd = cmd.exe /c "cd /d `"$keytoolFolder`" && $keytoolCommand"
Write-Log "[INFO] keytool command executed"
Write-Log "`n=== Output from: keytool ===`n$RunkeytoolCmd`n"
# Add-Content -Path $cmdLog -Value "`n=== Output from: keytool ===`n$RunkeytoolCmd`n"


# SSL update command
$binFolder = "C:\Program Files\Centric Software\C8\Wildfly\bin"
$binCommand = "c8_update_ssl_certificate_password.cmd centric8 CSIWildCard#1"

$RunBinCmd = cmd.exe /c "cd /d `"$binFolder`" && $binCommand"
# Add-Content -Path $cmdLog -Value "`n=== Output from: update SSL script ===`n$RunBinCmd`n"
Write-Log "[INFO] UpdateSSL Command executed"
Write-Log "`n=== Output from: update SSL script ===`n$RunBinCmd`n"
Write-Log "[SUCCESS] SSL script command executed"