$server = "localhost"     
$database = "C8"
$backupDir = "C:\Db Backup"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = "$backupDir\C8_$timestamp.bak"

if (!(Test-Path -Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir
}

# SQL query  = BACKUP DATABASE [C8] TO DISK = 'C:\QWERTY.bak' ;
$query = "BACKUP DATABASE [$database] TO DISK = N'$backupFile' WITH INIT, STATS = 25;"

# Execute using Invoke-Sqlcmd (requires SQL Server module)
Invoke-Sqlcmd -ServerInstance $server -Query $query