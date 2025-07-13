. (Join-Path $PSScriptRoot "..\Common\PathSpecifier.ps1")
. (Join-Path $PSScriptRoot "..\Common\logGenerator.ps1")


urllog "Script execution started."
urllog "DB backup Script located in: $($MyInvocation.MyCommand.Path)" "DEBUG"
urllog "Server parameter (Fetched from Configuration.properties): $server" "DEBUG"

# Determine if local or remote SQL server
$isLocalServer = ($server -eq $env:COMPUTERNAME)

# Choose backup path
if ($isLocalServer) {
    $dbbackupDir = $StandarddbbackupDir
    if (!(Test-Path -Path $dbbackupDir)) {
        urllog "Creating local Db backup folder at: $dbbackupDir"
        New-Item -ItemType Directory -Path $dbbackupDir | Out-Null
    }
} else {
    # Use shared folder (change this as per your real share)
    $dbbackupDir = "C:"
	if(! (Test-Path -Path $dbbackupDir)){
		New-Item -ItemType Directory -Path $dbbackupDir | Out-Null
	}
    urllog "Remote server detected"
	urllog "Backup will be saved to folder: $dbbackupDir" "DEBUG"
}

$database = Read-Host "Enter Database name"
$dbbackupfile = "$dbbackupDir\${database}_${Server}_$(Get-Date -Format "dd-MM-yyyy_HH-mm-ss").bak"

if ([string]::IsNullOrWhiteSpace($database)) {
    Write-Host "ERROR: Please enter valid database name"
	urllog "Script exited with exception. Because user entered Null or WhiteSpace" "ERROR"
    Exit 1
} 
urllog "Database parameter entered by user: '$database'"


Write-Host "Using $server" and $database Database


urllog "Attempting database backup for '$database'" 

try {
    #check if DB exists
    $dbCheckQuery = "SELECT name FROM sys.databases WHERE name = '$database';"
    $dbExists = Invoke-Sqlcmd -ServerInstance $server  -Username "sa" -Password "csisa" -Query $dbCheckQuery -ErrorAction Stop

    if ($dbExists) {
        #Backup the database
		urllog "Database '$database' exists. Proceeding with backup."
		
		if (!(Test-Path -Path $dbbackupDir)) {
			urllog "Creating Db backup Folder at $dbbackupDir"
			New-Item -ItemType Directory -Path $dbbackupDir | Out-Null
		}
		
        $query = "BACKUP DATABASE [$database] TO DISK = N'$dbbackupfile' WITH INIT, STATS = 25;"
        # Execute using Invoke-Sqlcmd (requires SQL Server module)
        Invoke-Sqlcmd -ServerInstance $server -Username "sa" -Password "csisa" -Query $query -ErrorAction Stop #SQL Authentication
        # Invoke-Sqlcmd -ServerInstance $server -Query $query   #Windows Authentication
        Write-Host "Backup completed"
        urllog "Backup completed successfully"
		urllog "Backup file: $dbbackupfile" "DEBUG"
		try{
			if(!($isLocalServer)){
				$destinationFile = Join-Path $StandarddbbackupDir (Split-Path $dbbackupfile -Leaf)
				Move-Item -Path "\\${server}\c$\$(Split-Path $dbbackupfile -Leaf)" -Destination $destinationFile
				urllog "Moved backup file from '$dbbackupfile' to '$destinationFile'" 
			}
			
		} catch {
			urllog "Failed to move backup file: $($_.Exception.Message)" "ERROR"
		}
    } else {
        $msg = "Database '$database' does not exist in server '$server'."       
		Write-Host $msg
        urllog $msg "ERROR"
		 throw $msg
		
    }
}
catch {
    $errorMsg = $_.Exception.Message
    Write-Host "ERROR: $errorMsg"
    urllog "Exception encountered: $errorMsg" "ERROR"
}




