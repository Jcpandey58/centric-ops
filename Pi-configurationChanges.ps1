$BackupLog = "C:\https_config\exposeUrl.log"

function WriteLog {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File $BackupLog -Append
}

$piFile = "C:\Program Files\Centric Software\C8\Wildfly\standalone\configuration\pi-configuration.properties"
$key = "com.centricsoftware.server.MessageProvider.CENTRICMESSAGEPROVIDER.CommonFromAddress"
$keyValue = "$key = noreply@centricsoftware.com"

$pi-configurationcontent = Get-Content $piFile

if ($pi-configurationcontent -match "^$key\s*=") {
    $pi-configurationcontent = $pi-configurationcontent -replace "^$key\s*=.*", $keyValue
	WriteLog "Message provider Key found"
} else {
    $pi-configurationcontent += $keyValue
}
$pi-configurationcontent | Set-Content $piFile

WriteLog "Updated Messge provider at pi-configuration.properties"