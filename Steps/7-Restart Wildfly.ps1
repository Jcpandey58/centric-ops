$RootFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
$logsPath = Join-Path $RootFolder "Logs"
$RestartwildflyLog = Join-Path $logsPath "ExposeUrl.log"

if (-not (Test-Path $RestartwildflyLog)) {
    New-Item -ItemType File -Path $RestartwildflyLog -Force | Out-Null
}

function WriteLog {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File $RestartwildflyLog -Append
}

$processesToKill = @("java", "node")
Stop-Service -Name "Centric Wildfly Service"
foreach ($processName in $processesToKill) {
    WriteLog "`n--- Processing $processName ---"
    try {
        $process = Get-Process -Name $processName -ErrorAction SilentlyContinue

        if ($process) {
            WriteLog "Found process(es) for '$processName'"
            WriteLog "Attempting to stop..."
            Stop-Process -InputObject $process -Force -ErrorAction Stop
            WriteLog "terminated process for '$processName'."
        } else {
            WriteLog "No running process found with the name '$processName'."
        }
    } catch {
        Write-Warning "Failed to terminate process '$processName'. Error: $($_.Exception.Message)"
        Write-Warning "You might need to run PowerShell as an administrator to stop this process."
    }
}

Write-Host "`nStarting Wildfly service"

Start-Service -Name "Centric Wildfly Service"

Write-Host "`nStarted Wildfly service"