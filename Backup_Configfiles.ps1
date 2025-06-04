# This script backs up three important config files for Centric Wildfly

# Get today’s date in format like 19-05-2025
$date = Get-Date -Format "dd-MM-yyyy"

# Create a backup folder like C:\Backup_19-05-2025
$backupFolder = "C:\Backup_$date"
New-Item -ItemType Directory -Path $backupFolder -Force

# Backup each file one by one

# 1. Backup pi-configuration.properties
Copy-Item "C:\Program Files\Centric Software\C8\Wildfly\standalone\configuration\pi-configuration.properties" `
          "$backupFolder\pi-configuration.properties" -Force

# 2. Backup standalone-pi-mssql.xml
Copy-Item "C:\Program Files\Centric Software\C8\Wildfly\standalone\configuration\standalone-pi-mssql.xml" `
          "$backupFolder\standalone-pi-mssql.xml" -Force

# 3. Backup standalone.conf.bat
Copy-Item "C:\Program Files\Centric Software\C8\Wildfly\bin\standalone.conf.bat" `
          "$backupFolder\standalone.conf.bat" -Force

# Show message
Write-Host "Backup completed in $backupFolder"
