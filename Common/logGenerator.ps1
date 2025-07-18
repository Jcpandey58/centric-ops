# $global:urlexposelog = Join-Path -Path (Join-Path -Path (Get-Location) -ChildPath "Logs") -ChildPath "exposeUrl.log"
$logsPath = Join-Path (Split-Path -Parent $PSScriptRoot) "Logs"
if (-not (Test-Path $logsPath)) {
    New-Item -ItemType Directory -Path $logsPath | Out-Null
}
$logFile = Join-Path $logsPath "centric-ps.log"
# $DbBackupLog = Join-Path $logsPath "Db-Backup.log"


function urllog {
    param ([string]$message, [string]$level = "INFO")

    # $logFile = $urlexposelog
    $maxSize = 100kB
    $maxBackups = 4

    if (Test-Path $logFile) {
        $fileInfo = Get-Item $logFile
        if ($fileInfo.Length -ge $maxSize) {
            $oldest = "$logFile.$maxBackups"
            if (Test-Path $oldest) { Remove-Item $oldest }

            for ($i = $maxBackups - 1; $i -ge 1; $i--) {
                $src = "$logFile.$i"
                $dst = "$logFile." + ($i + 1)
                if (Test-Path $src) {
                    Rename-Item $src $dst
                }
            }

            Rename-Item $logFile "$logFile.1"
        }
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss,fff"
	$paddedLevel = $level.PadRight(5)
    "[$timestamp] [$paddedLevel] -- $message" | Out-File $logFile -Append 
}
<# function dblog {
    param ([string]$message, [string]$level = "INFO")

    $logFile = $DbBackupLog
    $maxSize = 1MB
    $maxBackups = 11

    if (Test-Path $logFile) {
        $fileInfo = Get-Item $logFile
        if ($fileInfo.Length -ge $maxSize) {
            # Delete the oldest backup if max is exceeded
            $oldest = "$logFile.$maxBackups"
            if (Test-Path $oldest) {
                Remove-Item $oldest
            }

            for ($i = $maxBackups - 1; $i -ge 1; $i--) {
                $src = "$logFile.$i"
                $dst = "$logFile." + ($i + 1)
                if (Test-Path $src) {
                    Rename-Item $src $dst
                }
            }

            # Rotate current log
            Rename-Item $logFile "$logFile.1"
        }
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss,fff"
	$paddedLevel = $level.PadRight(5)
    "[$timestamp] [$paddedLevel] -- $message" | Out-File $logFile -Append 
} #>
