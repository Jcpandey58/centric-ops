. ".\PathSpecifier.ps1"

Copy-Item -Path $pfxUtilsPath -Destination $pkcsPath -Force
Write-Log "pfx file Updated at $pkcsPath ""SUCCESS"  