. (Join-Path $PSScriptRoot "..\Common\PathSpecifier.ps1")
. (Join-Path $PSScriptRoot "..\Common\logGenerator.ps1")

Copy-Item -Path $pfxUtilsPath -Destination $pkcsPath -Force
urllog "pfx file Updated at $pkcsPath ""SUCCESS"  