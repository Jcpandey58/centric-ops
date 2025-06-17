$BackupLog = "C:\https_config\exposeUrl.test.log"
$date = Get-Date -Format "dd-MM-yyyy"

function Write-Log {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File $BackupLog -Append
}

<# Copy-Item "C:\HttpsConfig\Utils\C8.pfx" `
          "C:\Program Files\Centric Software\C8\Wildfly\standalone\configuration\pkcs_stores" -Force
 #>		 
Copy-Item "C:\My space\https_UrlExpose\Utils\C8.pfx" `
          "C:\My space\" -Force
		  
Write-Log "pfx file replaced"
		   
		  