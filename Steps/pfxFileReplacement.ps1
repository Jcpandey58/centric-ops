. (Join-Path $PSScriptRoot "..\Common\PathSpecifier.ps1")
. (Join-Path $PSScriptRoot "..\Common\logGenerator.ps1")

Copy-Item -Path $pfxUtilsPath -Destination $pkcsPath -Force
Write-Log "pfx file Updated at $pkcsPath ""SUCCESS"  