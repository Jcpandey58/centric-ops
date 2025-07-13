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

Write-Host "Service '$ServiceName' current status: $($service.Status)"

switch ($Action.ToLower()) {
    "start" {
        if ($service.Status -ne "Running") {
            Start-Service -Name $ServiceName
            Write-Host "Service '$ServiceName' started."
        } else {
            Write-Host "Service '$ServiceName' is already running."
        }
    }
    "stop" {
        if ($service.Status -ne "Stopped") {
            Stop-Service -Name $ServiceName
            Write-Host "Service '$ServiceName' stopped."
        } else {
            Write-Host "Service '$ServiceName' is already stopped."
        }
    }
    "restart" {
        Restart-Service -Name $ServiceName
        Write-Host "Service '$ServiceName' restarted."
    }
    Default {
        Write-Host "Invalid action: $Action. Use Start, Stop, or Restart."
    }
}
