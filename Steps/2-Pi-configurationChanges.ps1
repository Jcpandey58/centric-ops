$RootFolder = "C:\HttpsUrlExpose"
$logsPath = Join-Path $RootFolder "Logs"
$PiConfigurationlog = Join-Path $logsPath "ExposeUrl.log"

if (-not (Test-Path $PiConfigurationlog)) {
    New-Item -ItemType File -Path $PiConfigurationlog -Force | Out-Null
}

function WriteLog {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File $PiConfigurationlog -Append
}

$piFile = "C:\Program Files\Centric Software\C8\Wildfly\standalone\configuration\pi-configuration.properties"
$key = "com.centricsoftware.server.MessageProvider.CENTRICMESSAGEPROVIDER.CommonFromAddress"
$keyValue = "$key = noreply@centricsoftware.com"

$piConfigurationcontent = Get-Content $piFile

if ($piConfigurationcontent -match "^$key\s*=") {
    $piConfigurationcontent = $piConfigurationcontent -replace "^$key\s*=.*", $keyValue
	WriteLog "[INFO] Message provider Key found"
} 
else {
#     $piConfigurationcontent += $keyValue
        Write-log "[Error] Message provider Key not found"
 }

$piConfigurationcontent | Set-Content $piFile

WriteLog "[SUCCESS] Updated Messge provider at pi-configuration.properties"