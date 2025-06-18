$RootFolder = "C:\HttpsUrlExpose"
$logsPath = Join-Path $RootFolder "Logs"
$PiConfigurationlog = Join-Path $logsPath "Restart Wildfly.log"

if (-not (Test-Path $PiConfigurationlog)) {
    New-Item -ItemType File -Path $PiConfigurationlog -Force | Out-Null
}

function WriteLog {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File $PiConfigurationlog -Append
}

$processesToKill = @("java", "node")

foreach ($processName in $processesToKill) {
    WriteLog "`n--- Processing $processName ---"
    try {
        $process = Get-Process -Name $processName -ErrorAction SilentlyContinue

        if ($process) {
            WriteLog "Found process(es) for '$processName'. Attempting to stop..."
            # Stop the process(es)
            Stop-Process -InputObject $process -Force -ErrorAction Stop
            Write-Host "Successfully terminated process(es) for '$processName'."
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