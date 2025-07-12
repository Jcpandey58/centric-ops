. ".\PathSpecifier.ps1"

Write-Host "Updating Standalone.conf.bat"
urllog "Updating Standalone.conf.bat" "INFO"

$lineToAdd = 'set "JAVA_OPTS=%JAVA_OPTS% -Djdk.tls.ephemeralDHKeySize=2048 -Djdk.tls.rejectClientInitiatedRenegotiation=true"'


$lines = Get-Content $baStandaloneConfBatFiletFile
$matchingLines = @()
urllog "Reading Standalone.conf.bat file""INFO"
foreach ($line in $lines) {
    if ($line -match "rejectClientInitiatedRenegotiation") {
        $matchingLines += $line
    }
}

if (-not $matchingLines) {
    Add-Content $StandaloneConfBatFile "$lineToAdd"
    urllog "Line added at end of standalone.conf.bat"
} else {
    urllog "Line already exists" "WARN"
}
Write-Host "Completed"
urllog "Completed Updating standalone.conf.bat"