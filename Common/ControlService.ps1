param (
    [string]$ServiceName,
    [string]$Action  # Accepts Start, Stop, or Restart
)

# Get the service by name
$service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue

if (-not $service) {
    Write-Host "Service '$ServiceName' not found."
    exit 1
}

urllog "Service '$ServiceName' current status: $($service.Status)"

switch ($Action.ToLower()) {
    "start" {
        if ($service.Status -ne "Running") {
            Start-Service -Name $ServiceName
            Write-Host "Service '$ServiceName' started."
            urllog "Service '$ServiceName' started."
        } else {
            Write-Host "Service '$ServiceName' is already running."
            urllog "Service '$ServiceName' is already running..."
        }
    }
    "stop" {
        if (!($service.Status -eq "Stopped")) {
            if ($service.DisplayName -like "Centric WildFly*") {
                $service.Refresh()
                $processesToKill = @("java", "node")
                Write-Host "Stopping Wildfly Service"
                 while ((Get-Service | Where-Object { $_.DisplayName -like $displayNamePattern } | Select-Object -First 1).Status -ne "Stopped") {
                    foreach ($processName in $processesToKill) {
                   
                        urllog "--- Processing $processName ---"
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
                }
            }
            Stop-Service -Name "$ServiceName" -Force -ErrorAction stop | Out-Null
            Write-Host "Service '$ServiceName' stopped."
            urllog "Service '$ServiceName' stopped."
        } else {
            Write-Host "Service '$ServiceName' is already stopped."
            urllog "Service '$ServiceName' is already stopped."
        }
    }
    "restart" {
        Restart-Service -Name $ServiceName
        Write-Host "Service '$ServiceName' restarted."
        urllog "Service '$ServiceName' restarted."
    }
    Default {
        Write-Host "Invalid action: $Action. Use Start, Stop, or Restart."
    }
}
