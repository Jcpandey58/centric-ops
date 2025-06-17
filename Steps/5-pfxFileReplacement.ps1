$RootFolder = "C:\HttpsUrlExpose"
$logsPath = Join-Path $RootFolder "Logs"
$pfxfilereplacementlog = Join-Path $logsPath "5-pfxFileReplacement.log"

if (-not (Test-Path $pfxfilereplacementlog)) {
    New-Item -ItemType File -Path $pfxfilereplacementlog -Force | Out-Null
}

function Write-Log {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File $pfxfilereplacementlog -Append
}

$pkcsPath = "C:\Program Files\Centric Software\C8\Wildfly\standalone\configuration\pkcs_stores"
 Copy-Item Join-Path $RootFolder"\Utils\C8.pfx" -Destination $pkcsPath -Force

# Copy-Item "C:\My space\https_UrlExpose\Utils\C8.pfx" `
#           "C:\My space\" -Force
		  
Write-Log "pfx file Updated at $pkcsPath "
		   
		  