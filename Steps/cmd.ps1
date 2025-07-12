. (Join-Path $PSScriptRoot "..\Common\PathSpecifier.ps1")
. (Join-Path $PSScriptRoot "..\Common\logGenerator.ps1")

# keytool command execution
$keytoolCommand = "keytool -list -keystore C8.pfx -storetype pkcs12 -storepass CSIWildCard#1"
$RunkeytoolCmd = cmd.exe /c "cd /d `"$pkcsPath`" && $keytoolCommand"
urllog "keytool command executed"
urllog "$RunkeytoolCmd`n"
# Add-Content -Path $cmdLog -Value "`n=== Output from: keytool ===`n$RunkeytoolCmd`n"

# SSL update command
$binCommand = "c8_update_ssl_certificate_password.cmd centric8 CSIWildCard#1"
$RunBinCmd = cmd.exe /c "cd /d `"$binFolder`" && $binCommand"
# Add-Content -Path $cmdLog -Value "`n=== Output from: update SSL script ===`n$RunBinCmd`n"
urllog "UpdateSSL Command executed"
urllog "$RunBinCmd`n"