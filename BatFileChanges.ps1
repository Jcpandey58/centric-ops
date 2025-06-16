$BackupLog = "C:\https_config\exposeUrl.log"

# $javaPath = "%JAVA_HOME%\bin"

function WriteLog {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File $BackupLog -Append
}
$lineToAdd = 'set "JAVA_OPTS=%JAVA_OPTS% -Djdk.tls.ephemeralDHKeySize=2048 -Djdk.tls.rejectClientInitiatedRenegotiation=true"'
$batFile = "C:\Users\jayavel.natraj\Documents\standalone.conf.bat"

$lines = Get-Content $batFile
$matchingLines = @()

foreach ($line in $lines) {
    if ($line -match "rejectClientInitiatedRenegotiation") {
        $matchingLines += $line
    }
}

if (-not $matchingLines) {
    Add-Content $batFile "$lineToAdd"
    WriteLog "Line added at end of standalone.conf.bat"
} else {
    WriteLog "Line already exists. No action taken."
}



<# # Add JAVA_OPTS if not present
if (-not (Select-String -Path $batFile -Pattern 'rejectClientInitiatedRenegotiation')) {
    Add-Content $batFile "`r`n$lineToAdd"
	WriteLog "Added JAVA_OPTS line"
} else {
	WriteLog "JAVA_OPTS already present"
} #>

# Add Java path to environment if not already there
<# $envPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($envPath -notlike "*$javaPath*") {
    [Environment]::SetEnvironmentVariable("Path", "$envPath;$javaPath", "Machine")
    WriteLog "Added Java path to system"
} else {
	WriteLog "Java path already in system path"
} #>
