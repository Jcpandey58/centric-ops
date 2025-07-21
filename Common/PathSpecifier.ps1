$RootFolder = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

# === BACKUP FILE PATHS ===
$StandarddbbackupDir = Join-Path $RootFolder "Db Backup" #Replace this path where u need the Db backup file
$backupFolder = Join-Path $RootFolder "File Backup\Backup_$(Get-Date -Format "dd-MM-yyyy_HH-mm-ss")"
$pfxUtilsPath = (Join-Path $RootFolder "\Utils\C8.pfx")

# === C8 WILDFLY FILE PATHS ===
$C8Path = "C:\Program Files\Centric Software\C8"
$c8wildflyfolder = Get-ChildItem -Path $C8Path -Directory |
    Where-Object { $_.Name -like "Wildfly*" } |
    Select-Object -First 1 -ExpandProperty FullName
$keytoolFolder = Join-Path $c8wildflyfolder "standalone\configuration\pkcs_stores"
$pkcsPath = Join-Path $c8wildflyfolder "standalone\configuration\pkcs_stores\"
$piConfigurationPropertiesFile = Join-Path $c8wildflyfolder "standalone\configuration\pi-configuration.properties"
$StandalonePixmlFile= Join-Path $c8wildflyfolder "standalone\configuration\standalone-pi.xml"
$StandalonePimssqlxmlFile=Join-Path $c8wildflyfolder "standalone\configuration\standalone-pi-mssql.xml"
$binFolder = Join-Path $c8wildflyfolder "bin" 
$StandaloneConfBatFile=Join-Path $binFolder "standalone.conf.bat" 


$ConfigFile = Join-Path $RootFolder "Configuration.properties"
$Config = @{}
if (Test-Path $ConfigFile) {
    Get-Content $ConfigFile | ForEach-Object {
        if ($_ -match '^(.*?)=(.*?)$') {
            $Config[$matches[1].Trim()] = $matches[2].Trim().ToLower()
        }
    }
} else {
    Write-Host "Config file not found: $ConfigFile"
    Exit 1
}

#Capturing from Configuration.Properties file
if($Config["db.server"] -eq "localhost"){
	$server = $env:COMPUTERNAME
}
else{
	$server = $Config["db.server"]
}

#Service name definition
# display name pattern to search for Wildfly
$displayNamePattern = "Centric WildFly*"
# Search for service where the display name matches the pattern
$Wildflyservice = Get-Service | Where-Object { $_.DisplayName -like $displayNamePattern } | Select-Object -First 1
$PDFservice = "Centric PDF Service"
$Imageservice = "CentricImageService"


$EnableDbBackup = $Config["db.backup"] -eq "true"
$EnableUrlExpose = $Config["url.expose"] -eq "true"
# Service control toggles
$EnableRestartWildFly = $Config["restart.WildFly.service"] -eq "true"
$EnableStopWildFly = $Config["stop.WildFly.service"] -eq "true"
$EnableStartWildFly = $Config["start.WildFly.service"] -eq "true"

$EnableStopPDF = $Config["stop.PDF.service"] -eq "true"
$EnableStartPDF = $Config["start.PDF.service"] -eq "true"
$EnableRestartPDF = $Config["restart.PDF.service"] -eq "true"

$EnableStopImage = $Config["stop.Image.service"] -eq "true"
$EnableStartImage = $Config["start.Image.service"] -eq "true"
$EnableRestartImage = $Config["restart.Image.service"] -eq "true"