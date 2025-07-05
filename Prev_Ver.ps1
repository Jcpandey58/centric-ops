$cwd = Get-Location
$logsPath = Join-Path $cwd "Logs"
# New-Item -Path $logsPath -ItemType Directory -Force

if (-not (Test-Path $logsPath)) {
    New-Item -ItemType Directory -Path $logsPath | Out-Null
}

$exposeUrlLog = Join-Path $logsPath "exposeUrl.log"

if (-not (Test-Path $exposeUrlLog)) {
    New-Item -ItemType File -Path $exposeUrlLog -Force | Out-Null
}

function Log {
    param ([string]$msg)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $msg" | Out-File -FilePath $exposeUrlLog -Append
}

#=== List of step scripts ===
$steps = @(
    "1-Backup_Configfiles.ps1",
	"2-Pi-configurationChanges.ps1",
    "3B-Standalone-pi-mssql-changes.ps1",
	"4-BatFileChanges.ps1",
    "5-pfxFileReplacement.ps1",
    "6-cmd.ps1",
    "7-Restart Wildfly"
)

# === Run each step ===
foreach ($script in $steps) {
    Log "Running: $script"
     & ".\Steps\$script"
    Log "$script finished"
}

Write-Host "All steps completed`nURL exposed"
