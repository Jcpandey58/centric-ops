# Logging function with logging level support
function Write-Log {
    param (
        [string]$message,
        [string]$level = "INFO"
    )
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    "$time - [$level] - $message" | Out-File -FilePath $logPath -Append
}

# Example of additional logging:
Write-Log "Script execution started. Script located in: $RootFolder" "INFO"
Write-Log "Server parameter: $server" "DEBUG"
Write-Log "Attempting database backup for '$database'" "INFO"

try {
    $dbCheckQuery = "SELECT name FROM sys.databases WHERE name = '$database';"
    $dbExists = Invoke-Sqlcmd -ServerInstance $server -Query $dbCheckQuery

    if ($dbExists) {
        Write-Log "Database '$database' exists. Proceeding with backup." "INFO"
        $query = "BACKUP DATABASE [$database] TO DISK = N'$backupFile' WITH INIT, STATS = 25;"
        Invoke-Sqlcmd -ServerInstance $server -Query $query
        Write-Log "Backup completed successfully. Backup file: $backupFile" "SUCCESS"
        Write-Host "✅ Backup completed: $backupFile"
    } else {
        $msg = "Database '$database' does not exist on server '$server'."
        Write-Log $msg "ERROR"
        Write-Host "❌ $msg"
    }
}
catch {
    $errorMsg = $_.Exception.Message
    Write-Log "Exception encountered: $errorMsg" "EXCEPTION"
    Write-Host "❌ ERROR: $errorMsg"
}

Write-Log "Script execution ended." "INFO"
