# New-Item -Path "C:\https_config" -ItemType Directory -Force
$RootFolder = "C:\HttpsUrlExpose"
$logsPath = Join-Path $RootFolder "Logs"
$BackupLog = Join-Path $logsPath "ExposeUrl.log"

if (-not (Test-Path $BackupLog)) {
    New-Item -ItemType File -Path $BackupLog -Force | Out-Null
}

$date = Get-Date -Format "dd-MM-yyyy"
$timestamp = Get-Date -Format "dd-MM-yyyy_HH-mm-ss"
function Write-Log {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File $BackupLog -Append
}

$backupFolder = Join-Path $RootFolder "File Backup\Backup_$timestamp" 
New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null

$piConfigurationPropertiesFile = "C:\Program Files\Centric Software\C8\Wildfly\standalone\configuration\pi-configuration.properties"
$StandalonePixmlFile="C:\Program Files\Centric Software\C8\Wildfly\standalone\configuration\standalone-pi.xml" 
$StandaloneConfBatFile="C:\Program Files\Centric Software\C8\Wildfly\bin\standalone.conf.bat" 

Copy-Item -Path $piConfigurationPropertiesFile -Destination "$backupFolder\pi-configuration.properties" -Force
          Write-Log "[INFO] pi-configuration.properties Copied to $backupFolder"

Copy-Item -Path $StandalonePixmlFile -Destination "$backupFolder\standalone-pi.xml" -Force
          Write-Log "[INFO] standalone-pi.xml Copied to $backupFolder"

Copy-Item -Path $StandaloneConfBatFile -Destination "$backupFolder\standalone.conf.bat" -Force
		  Write-Log "[INFO] standalone.conf.bat Copied to $backupFolder`n"

Write-Host "Backup completed in $backupFolder"
Write-Log "[SUCCESS] Backup completed in $backupFolder"
