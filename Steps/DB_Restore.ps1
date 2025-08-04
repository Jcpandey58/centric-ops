param(
    [string]$serverName = "localhost",
    [string]$databaseName = "C8",
    [string]$backupFile = "C:\Backup\YourDatabase.bak",
    [string]$restorePath = "C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA"
)

Import-Module SqlServer

# Establish SQL connection
$connectionString = "Server=$serverName;Database=master;Integrated Security=True"

# Get file list from backup
$fileListQuery = "RESTORE FILELISTONLY FROM DISK = N'$backupFile'"
$fileList = Invoke-Sqlcmd -ConnectionString $connectionString -Query $fileListQuery

# Prepare MOVE statements dynamically
$moveStatements = ""
foreach ($file in $fileList) {
    $logicalName = $file.LogicalName

    if ($file.Type -eq 'L') {
        $extension = ".ldf"
    } elseif ($file.Type -eq 'S') {
        $extension = ".ndf"
    } elseif ($file.FileGroupName -eq "PRIMARY") {
        $extension = ".mdf"
    } else {
        $extension = ".ndf"
    }

    $targetFile = Join-Path $restorePath "$logicalName$extension"
    $moveStatements += "MOVE N'$logicalName' TO N'$targetFile',`n"
}

# Remove trailing comma and newline
$moveStatements = $moveStatements.TrimEnd(",`n")

# Check if database exists
$dbExistsQuery = "SELECT COUNT(*) AS DBExists FROM sys.databases WHERE name = '$databaseName'"
$dbExists = Invoke-Sqlcmd -ConnectionString $connectionString -Query $dbExistsQuery | Select-Object -ExpandProperty DBExists

# Prepare RESTORE DATABASE query
if ($dbExists -eq 1) {
    Write-Host "Database exists. Performing RESTORE WITH REPLACE."
    $restoreQuery = @"
RESTORE DATABASE [$databaseName]
FROM DISK = N'$backupFile'
WITH REPLACE,
$moveStatements,
STATS = 5
"@
} else {
    Write-Host "Database does not exist. Restoring database."
    $restoreQuery = @"
RESTORE DATABASE [$databaseName]
FROM DISK = N'$backupFile'
WITH
$moveStatements,
STATS = 5
"@
}

# Execute restore
Invoke-Sqlcmd -ConnectionString $connectionString -Query $restoreQuery

Write-Host "Database restore completed for: $databaseName"
