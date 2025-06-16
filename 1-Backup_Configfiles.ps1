New-Item -Path "C:\https_config" -ItemType Directory -Force
$BackupLog = "C:\https_config\exposeUrl.log"
$date = Get-Date -Format "dd-MM-yyyy"

function Write-Log {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File $BackupLog -Append
}


$backupFolder = "C:\https_config\Backup_$date"
New-Item -ItemType Directory -Path $backupFolder -Force

Copy-Item "C:\Program Files\Centric Software\C8\Wildfly\standalone\configuration\pi-configuration.properties" `
          "$backupFolder\pi-configuration.properties" -Force

Copy-Item "C:\Program Files\Centric Software\C8\Wildfly\standalone\configuration\standalone-pi-mssql.xml" `
          "$backupFolder\standalone-pi-mssql.xml" -Force

Copy-Item "C:\Program Files\Centric Software\C8\Wildfly\bin\standalone.conf.bat" `
          "$backupFolder\standalone.conf.bat" -Force
		  

Write-Log "Backup completed in $backupFolder"
