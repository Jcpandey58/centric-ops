 ".\PathSpecifier.ps1"
 ".\logGenerator.ps1"

    
$database = Read-Host "Enter Database name"
if ([string]::IsNullOrWhiteSpace($database)) {
    Write-Host "ERROR: Please enter valid database name"
    Exit 1
} 

if (!(Test-Path -Path $dbbackupDir)) {
    New-Item -ItemType Directory -Path $dbbackupDir | Out-Null
}

Write-Host "Using $server" and $database Database
# SQL query  = BACKUP DATABASE [C8] TO DISK = 'C:\QWERTY.bak' ;
dblog "Script execution started."
dblog "Script located in: $RootFolder" "INFO"
dblog "Server parameter: $server" "DEBUG"
dblog "Attempting database backup for '$database'" "INFO"

try {
    #check if DB exists
    $dbCheckQuery = "SELECT name FROM sys.databases WHERE name = '$database';"
    $dbExists = Invoke-Sqlcmd -ServerInstance $server -Query $dbCheckQuery

    if ($dbExists) {
        #Backup the database
        dblog "Database '$database' exists. Proceeding with backup." "INFO"
        $query = "BACKUP DATABASE [$database] TO DISK = N'$dbbackupfile' WITH INIT, STATS = 25;"
        # Execute using Invoke-Sqlcmd (requires SQL Server module)
        Invoke-Sqlcmd -ServerInstance $server -Query $query
        Write-Host "Backup completed: $dbbackupfile"
        dblog "Backup completed successfully. Backup file: $dbbackupfile" "SUCCESS"
    } else {
        $msg = "Database '$database' does not exist in server '$server'."       
        Write-Host $msg
        dblog $msg "ERROR"
    }
}
catch {
    $errorMsg = $_.Exception.Message
    Write-Host "ERROR: $errorMsg"
    dblog "Exception encountered: $errorMsg" "EXCEPTION"
}




