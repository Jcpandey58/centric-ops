$c8wildflyfolder = "C:\Program Files\Centric Software\C8\Wildfly"
$server = "localhost" #Changing this will reflect in DB backup only
$RootFolder = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$logsPath = Join-Path $RootFolder "Logs"
if (-not (Test-Path $logsPath)) {
    New-Item -ItemType Directory -Path $logsPath | Out-Null
}
$DbBackupLog = Join-Path $logsPath "Db-Backup.log"
$dbbackupDir = "C:\Db Backup"
$dbbackupfile = "$dbbackupDir\C8_$(Get-Date -Format "yyyy-MMM-dd_HH-mm-ss").bak"
$urlexposelog = Join-Path $logsPath "ExposeUrl.log"
$backupFolder = Join-Path $RootFolder "File Backup\Backup_$(Get-Date -Format "dd-MM-yyyy_HH-mm-ss")" 
$keytoolFolder = Join-Path $c8wildflyfolder "standalone\configuration\pkcs_stores"
$pkcsPath = Join-Path $c8wildflyfolder "standalone\configuration\pkcs_stores\"
$piConfigurationPropertiesFile = Join-Path $c8wildflyfolder "standalone\configuration\pi-configuration.properties"
$StandalonePixmlFile= Join-Path $c8wildflyfolder "standalone\configuration\standalone-pi.xml"
$StandalonePimssqlxmlFile=Join-Path $c8wildflyfolder "standalone\configuration\standalone-pi-mssql.xml"
$binFolder = Join-Path $c8wildflyfolder "bin" 
$StandaloneConfBatFile=Join-Path $binFolder "standalone.conf.bat" 
$pfxUtilsPath = (Join-Path $RootFolder "\Utils\C8.pfx")