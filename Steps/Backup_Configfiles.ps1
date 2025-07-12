. ".\PathSpecifier.ps1"

if (-not (Test-Path $backupFolder)) {
    New-Item -ItemType Directory -Path $backupFolder | Out-Null
    urllog "Backup folder created : Backup_$(Get-Date -Format "dd-MM-yyyy_HH-mm-ss")"
    urllog "Located at $backupFolder" "DEBUG"
}
$content = Get-Content $StandaloneConfBatFile
$line = $content | Select-String -Pattern '-Djboss.server.default.config=' -SimpleMatch
if ($line) {
    $configFile = $line.Line.Split('=')[-1].Trim('"')
    urllog "Searching Config file for backup"
    urllog "Found Counfig file $configFile" "DEBUG"

    if ($configFile -eq "standalone-pi.xml") { 
        Copy-Item -Path $StandalonePixmlFile -Destination "$backupFolder\standalone-pi.xml" -Force
        urllog "standalone-pi.xml Copied to $backupFolder"
    }
    elseif($configFile -eq "standalone-pi-mssql.xml") {
        Copy-Item -Path $StandalonePimssqlxmlFile -Destination "$backupFolder\standalone-pi-mssql.xml" -Force
        urllog "standalone-pi-mssql.xml Copied to $backupFolder"
    }
    else{
         urllog "Unknown config file type: $configFile" "ERROR"
         Exit 1
    }
} else {
    urllog "Could not detect config file from $confPath" "ERROR"
    Exit 1
}

Copy-Item -Path $piConfigurationPropertiesFile -Destination "$backupFolder\pi-configuration.properties" -Force
          urllog "pi-configuration.properties Copied to $backupFolder"

Copy-Item -Path $StandaloneConfBatFile -Destination "$backupFolder\standalone.conf.bat" -Force
		  urllog "standalone.conf.bat Copied to $backupFolder`n"

Write-Host "Backup completed in $backupFolder"
urllog "Backup completed in $backupFolder"
