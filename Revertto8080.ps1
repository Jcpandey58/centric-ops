cwd = Get-Location
$logsPath = Join-Path $cwd "Logs"
# New-Item -Path $logsPath -ItemType Directory -Force

if (-not (Test-Path $logsPath)) {
    New-Item -ItemType Directory -Path $logsPath | Out-Null
}

$Revertlog = Join-Path $logsPath "Revertingto8080.log"

if (-not (Test-Path $Revertlog)) {
    New-Item -ItemType File -Path $Revertlog -Force | Out-Null
}