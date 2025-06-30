$RootFolder = "C:\HttpsUrlExpose"
$logsPath = Join-Path $RootFolder "Logs"
$pfxfilereplacementlog =Join-Path $logsPath "ExposeUrl.log"

if (-not (Test-Path $pfxfilereplacementlog)) {
    New-Item -ItemType File -Path $pfxfilereplacementlog -Force | Out-Null
}

function Write-Log {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File $pfxfilereplacementlog -Append
}

$pkcsPath = "C:\Program Files\Centric Software\C8\Wildfly\standalone\configuration\pkcs_stores\"
$pfxUtilsPath = (Join-Path $RootFolder "\Utils\C8.pfx")
 Copy-Item -Path $pfxUtilsPath -Destination $pkcsPath -Force

		  
Write-Log "[SUCCESS] pfx file Updated at $pkcsPath "
		   
		  