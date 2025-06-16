# === Set up log file ===
$log = "Logs\combined.log"
if (-not (Test-Path "Logs")) {
    New-Item -ItemType Directory -Path "Logs" | Out-Null
}

function Log {
    param ([string]$msg)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $msg" | Out-File -FilePath $log -Append
}

# === List of step scripts ===
$steps = @(
    "1-Backup_Configfiles.ps1",
    "2-BatFileChanges.ps1",
    "3-pfxFileReplacement.ps1",
    "4-Pi-configurationChanges.ps1",
    "5-Standalone-pi-xml-changes.ps1",
    "6-cmd.ps1"
)

# === Run each step ===
foreach ($script in $steps) {
    Log "Running: $script"
    & ".\Steps\$script"
    Log "$script finished"
}

Log "All steps completed."
