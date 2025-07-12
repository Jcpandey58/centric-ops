. ".\PathSpecifier.ps1"

$Wildflyservice = Get-Service -Name "WFAS20SVC" -ErrorAction SilentlyContinue

$processesToKill = @("java", "node")
foreach ($processName in $processesToKill) {
    urllog "`n--- Processing $processName ---"
    try {
        $process = Get-Process -Name $processName -ErrorAction SilentlyContinue

        if ($process) {
            urllog "Found process(es) for '$processName'"
            urllog "Attempting to stop..."
            Stop-Process -InputObject $process -Force -ErrorAction Stop
            urllog "terminated process for '$processName'."
        } else {
            urllog "No running process found with the name '$processName'."
        }
    } catch {
        Write-Warning "Failed to terminate process '$processName'. Error: $($_.Exception.Message)"
        Write-Warning "You might need to run PowerShell as an administrator to stop this process."
    }
}

if ($Wildflyservice.Status -eq "Stopped") {
    urllog "Wildfly service is not running" "DEBUG"
} else {
    urllog "Stopping Centric Wildfly Service"
    Stop-Service -Name "WFAS20SVC" -ErrorAction stop
}

Write-Host "`nStarting Wildfly service"
urllog "Starting Wildfly Service"
Start-Service -Name "Centric Wildfly Service"
if ($Wildflyservice.Status -eq "Running") {
    urllog "Wildfly service is running" "DEBUG"
} 
Write-Host "`nStarted Wildfly service"