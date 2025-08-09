. (Join-Path $PSScriptRoot "..\Common\PathSpecifier.ps1")
. (Join-Path $PSScriptRoot "..\Common\logGenerator.ps1")

if ($Wildflyservice) {
    $ServiceName = $Wildflyservice.Name
    $ServiceDisplayName = $Wildflyservice.DisplayName
    urllog "Detected Service Name: $ServiceName" "DEBUG"
    urllog "Detected Display Name: $ServiceDisplayName" "DEBUG"
} else {
    Write-Host "Cannot find WildFly service. Check log for details"
	urllog  "No WildFly service with display name pattern '$displayNamePattern' was found." "ERROR"
	urllog "Make sure that the service is installed."
    Exit 1
}

# $Wildflyservice = Get-Service -Name "WFAS20SVC" -ErrorAction SilentlyContinue

$Wildflyservice.refresh()
$processesToKill = @("java", "node")
urllog "Stopping $ServiceDisplayName"

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
                    urllog $Wildflyservice.Status
}

Stop-Service -Name "$ServiceName" -Force -ErrorAction stop | Out-Null

if ($ServiceName.Status -eq "Stopped") {
    urllog "$ServiceDisplayName is not running" "DEBUG"
} else {
    urllog "Stopping $ServiceDisplayName"
    Stop-Service -Name "$ServiceName" -Force -ErrorAction stop
}

Write-Host "Starting $ServiceDisplayName"
urllog "Starting Wildfly Service"
Start-Service -Name "$ServiceName"
if ($Wildflyservice.Status -eq "Running") {
    urllog "$ServiceDisplayName is running" "DEBUG"
	Write-Host "$ServiceDisplayName - Status - Running"
}
