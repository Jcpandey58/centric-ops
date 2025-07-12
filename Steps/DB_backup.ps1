. (Join-Path $PSScriptRoot "..\Common\PathSpecifier.ps1")
. (Join-Path $PSScriptRoot "..\Common\logGenerator.ps1")

dblog "Script execution started."
dblog "DB backup Script located in: $($MyInvocation.MyCommand.Path)" "DEBUG"
dblog "Server parameter: $server" "DEBUG"

# Determine if local or remote SQL server
$isLocalServer = ($server -eq "localhost" -or $server -eq $env:COMPUTERNAME)

# Choose backup path
if ($isLocalServer) {
    $dbbackupDir = $StandarddbbackupDir
    if (!(Test-Path -Path $dbbackupDir)) {
        dblog "Creating local Db backup folder at: $dbbackupDir"
        New-Item -ItemType Directory -Path $dbbackupDir | Out-Null
    }
} else {
    # Use shared folder (change this as per your real share)
    $dbbackupDir = "C:"
	if(! (Test-Path -Path $dbbackupDir)){
		New-Item -ItemType Directory -Path $dbbackupDir | Out-Null
	}
    dblog "Remote server detected"
	dblog "Backup will be saved to folder: $dbbackupDir" "DEBUG"
}

$database = Read-Host "Enter Database name"
$dbbackupfile = "$dbbackupDir\${database}_${Server}_$(Get-Date -Format "dd-MM-yyyy_HH-mm-ss").bak"

if ([string]::IsNullOrWhiteSpace($database)) {
    Write-Host "ERROR: Please enter valid database name"
	dblog "Script exited with exception. Because user entered Null or WhiteSpace"
    Exit 1
} 
dblog "Database parameter entered by user: '$database'"


Write-Host "Using $server" and $database Database


dblog "Attempting database backup for '$database'" 

try {
    #check if DB exists
    $dbCheckQuery = "SELECT name FROM sys.databases WHERE name = '$database';"
    $dbExists = Invoke-Sqlcmd -ServerInstance $server  -Username "sa" -Password "csisa" -Query $dbCheckQuery -ErrorAction Stop

    if ($dbExists) {
        #Backup the database
		dblog "Database '$database' exists. Proceeding with backup."
		
		if (!(Test-Path -Path $dbbackupDir)) {
			dblog "Creating Db backup Folder at $dbbackupDir"
			New-Item -ItemType Directory -Path $dbbackupDir | Out-Null
		}
		
        $query = "BACKUP DATABASE [$database] TO DISK = N'$dbbackupfile' WITH INIT, STATS = 25;"
        # Execute using Invoke-Sqlcmd (requires SQL Server module)
        Invoke-Sqlcmd -ServerInstance $server -Username "sa" -Password "csisa" -Query $query -ErrorAction Stop #SQL Authentication
        # Invoke-Sqlcmd -ServerInstance $server -Query $query   #Windows Authentication
        Write-Host "Backup completed"
        dblog "Backup completed successfully"
		dblog "Backup file: $dbbackupfile" "DEBUG"
		try{
			$destinationFile = Join-Path $StandarddbbackupDir (Split-Path $dbbackupfile -Leaf)
			Move-Item -Path "\\${server}\c$\$(Split-Path $dbbackupfile -Leaf)" -Destination $destinationFile
			dblog "Moved backup file from '$dbbackupfile' to '$destinationFile'" 
		} catch {
			dblog "Failed to move backup file: $($_.Exception.Message)" "ERROR"
		}
    } else {
        $msg = "Database '$database' does not exist in server '$server'."       
        Write-Host $msg
        dblog $msg "ERROR"
    }
}
catch {
    $errorMsg = $_.Exception.Message
    Write-Host "ERROR: $errorMsg"
    dblog "Exception encountered: $errorMsg" "ERROR"
}