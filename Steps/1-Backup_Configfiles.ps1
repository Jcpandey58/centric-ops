# New-Item -Path "C:\https_config" -ItemType Directory -Force
$RootFolder = "C:\HttpsUrlExpose"
$logsPath = Join-Path $RootFolder "Logs"
$BackupLog = Join-Path $logsPath "1-Backup_Configfiles.log"

if (-not (Test-Path $BackupLog)) {
    New-Item -ItemType File -Path $BackupLog -Force | Out-Null
}

$date = Get-Date -Format "dd-MM-yyyy"

function Write-Log {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File $BackupLog -Append
}

$backupFolder = Join-Path $RootFolder "Utils\Backup_$date"
New-Item -ItemType Directory -Path $backupFolder -Force

Copy-Item "C:\Program Files\Centric Software\C8\Wildfly\standalone\configuration\pi-configuration.properties" `
          "$backupFolder\pi-configuration.properties" -Force

Copy-Item "C:\Program Files\Centric Software\C8\Wildfly\standalone\configuration\standalone-pi-mssql.xml" `
          "$backupFolder\standalone-pi-mssql.xml" -Force

Copy-Item "C:\Program Files\Centric Software\C8\Wildfly\bin\standalone.conf.bat" `
          "$backupFolder\standalone.conf.bat" -Force
		  

Write-Log "Backup completed in $backupFolder"
