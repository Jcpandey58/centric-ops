Write-Host "Updating Standalone.conf.bat"

$RootFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
$logsPath = Join-Path $RootFolder "Logs"
$StandalonePixmlLog = Join-Path $logsPath "ExposeUrl.log"

if (-not (Test-Path $StandalonePixmlLog)) {
    New-Item -ItemType File -Path $StandalonePixmlLog -Force | Out-Null
}

function WriteLog {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File $StandalonePixmlLog -Append
}
$lineToAdd = 'set "JAVA_OPTS=%JAVA_OPTS% -Djdk.tls.ephemeralDHKeySize=2048 -Djdk.tls.rejectClientInitiatedRenegotiation=true"'
$batFile = "C:\Program Files\Centric Software\C8\Wildfly\bin\standalone.conf.bat"

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
    WriteLog "[WARN]Line already exists"
}
Write-Host "Completed"
WriteLog "Completed Updating standalone.conf.bat"