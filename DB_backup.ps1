$RootFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
$logsPath = Join-Path $RootFolder "Logs"
$DbBackupLog = Join-Path $logsPath "Db-Backup.log"
$server = Read-Host "Enter server name (default: localhost)"
if ([string]::IsNullOrWhiteSpace($server)) {
    $server = "localhost"
}     
$database = "C8"
$backupDir = "C:\Db Backup"
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$backupFile = "$backupDir\C8_$timestamp.bak"


if (!(Test-Path -Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir | Out-Null
}
function Write-Log {
    param ([string]$message, [string]$level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - [$level] - $message" | Out-File $DbBackupLog -Append
}

Write-Host "Using $server" and C8 Database
# SQL query  = BACKUP DATABASE [C8] TO DISK = 'C:\QWERTY.bak' ;
Write-Log "Script execution started."
Write-Log "Script located in: $RootFolder" "INFO"
Write-Log "Server parameter: $server" "DEBUG"
Write-Log "Attempting database backup for '$database'" "INFO"

try {
    # Step 1: Check if DB exists
    $dbCheckQuery = "SELECT name FROM sys.databases WHERE name = '$database';"
    $dbExists = Invoke-Sqlcmd -ServerInstance $server -Query $dbCheckQuery

    if ($dbExists) {
        # Step 2: Backup the database
        $query = "BACKUP DATABASE [$database] TO DISK = N'$backupFile' WITH INIT, STATS = 25;"
        # Execute using Invoke-Sqlcmd (requires SQL Server module)
        Invoke-Sqlcmd -ServerInstance $server -Query $query
        Write-Host "✅ Backup completed: $backupFile"
        Write-Log "[SUCCESS] Backup completed: $backupFile"
    } else {
        $msg = "Database '$database' does not exist on server '$server'."
        Write-Host $msg
        Write-Log "[ERROR] $msg"
    }
}
catch {
    $errorMsg = $_.Exception.Message
    Write-Host "ERROR: $errorMsg"
    Write-Log "[EXCEPTION] $errorMsg"
}




