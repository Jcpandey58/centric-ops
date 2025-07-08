$RootFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
$logsPath = Join-Path $RootFolder "Logs"
$PiConfigurationlog = Join-Path $logsPath "ExposeUrl.log"

if (-not (Test-Path $PiConfigurationlog)) {
    New-Item -ItemType File -Path $PiConfigurationlog -Force | Out-Null
}

function WriteLog {
    param ([string]$message)

    $logFile = $PiConfigurationlog
    $maxSize = 1MB

    if (Test-Path $logFile) {
        $fileInfo = Get-Item $logFile
        if ($fileInfo.Length -ge $maxSize) {
            # Find next available log number
            $i = 1
            while (Test-Path "$logFile.$i") {
                $i++
            }

            # Rename current log to next available number
            Rename-Item $logFile "$logFile.$i"
        }
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File $logFile -Append -Encoding UTF8

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
        WriteLog "[Error] Message provider Key not found"
 }

$piConfigurationcontent | Set-Content $piFile

WriteLog "[SUCCESS] Updated Messge provider at pi-configuration.properties"