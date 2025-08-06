# Assuming $Config is already loaded and service names defined via PathSpecifier.ps1
$controlServiceScript = ".\Common\ControlService.ps1"
$steps = @()

### 1. Stop Services
if ($EnableStopPDF) {
    $steps += @{ type = "command"; value = "& '$controlServiceScript' -ServiceName '$PDFservice' -Action 'Stop'" }
}
if ($EnableStopImage) {
    $steps += @{ type = "command"; value = "& '$controlServiceScript' -ServiceName '$Imageservice' -Action 'Stop'" }
}
if ($EnableStopWildFly) {
    $steps += @{ type = "command"; value = "& '$controlServiceScript' -ServiceName '$($Wildflyservice.Name)' -Action 'Stop'" }
}

### 2. DB Backup
if ($EnableDbBackup) {
    $steps += @{ type = "script"; value = "Backup_Database.ps1" }  # Add this in your Steps folder
}

### 3. DB Restore (optional/placeholder)
if ($EnableDbRestore) {
    # $steps += @{ type = "script"; value = "Restore_Database.ps1" }  # Under implementation
    log "DB Restore opted" 
}

### 4. URL Expose
if ($EnableUrlExpose) {
    $steps += @{ type = "script"; value = "Backup_Configfiles.ps1" }
    $steps += @{ type = "script"; value = "Pi-configurationChanges.ps1" }

    # Detect config file logic
    $content = Get-Content $StandaloneConfBatFile
    $line = $content | Where-Object { ($_ -notmatch '^\s*rem') -and ($_ -match '-Djboss.server.default.config=') } | Select-Object -First 1
    if ($line) {
        $configFile = $line.Split('=')[-1].Trim('"')
        urllog "Detected config file: $configFile" "DEBUG"
    } else {
        urllog "Could not detect config file from $StandaloneConfBatFile" "ERROR"
        Exit 1
    }

    switch ($configFile) {
        "standalone-pi.xml"        { $steps += @{ type = "script"; value = "pi-xml-changes.ps1" } }
        "standalone-pi-mssql.xml" { $steps += @{ type = "script"; value = "pi-mssql-changes.ps1" } }
        default {
            urllog "Unknown config file type: $configFile" "ERROR"
            Exit 1
        }
    }

    $steps += @{ type = "script"; value = "BatFileChanges.ps1" }
    $steps += @{ type = "script"; value = "pfxFileReplacement.ps1" }
    $steps += @{ type = "script"; value = "cmd.ps1" }
    $steps += @{ type = "script"; value = "RestartWildfly.ps1" }
}

### 5. Start Services
if ($EnableStartPDF) {
    $steps += @{ type = "command"; value = "& '$controlServiceScript' -ServiceName '$PDFservice' -Action 'Start'" }
}
if ($EnableStartImage) {
    $steps += @{ type = "command"; value = "& '$controlServiceScript' -ServiceName '$Imageservice' -Action 'Start'" }
}
if ($EnableStartWildFly) {
    $steps += @{ type = "command"; value = "& '$controlServiceScript' -ServiceName '$($Wildflyservice.Name)' -Action 'Start'" }
}

### 6. Restart Services
if ($EnableRestartPDF) {
    $steps += @{ type = "command"; value = "& '$controlServiceScript' -ServiceName '$PDFservice' -Action 'Restart'" }
}
if ($EnableRestartImage) {
    $steps += @{ type = "command"; value = "& '$controlServiceScript' -ServiceName '$Imageservice' -Action 'Restart'" }
}
if ($EnableRestartWildFly) {
    $steps += @{ type = "command"; value = "& '$controlServiceScript' -ServiceName '$($Wildflyservice.Name)' -Action 'Restart'" }
}

### Log the planned steps
urllog "Execution order:"
$steps | ForEach-Object { urllog "$($_.type): $($_.value)" }

### Execution Loop
foreach ($step in $steps) {
    try {
        switch ($step.type) {
            "script" {
                urllog "Running script: $($step.value)"
                & ".\Steps\$($step.value)"
            }
            "command" {
                urllog "Running command: $($step.value)"
                Invoke-Expression $step.value
            }
        }
        urllog "$($step.value) executed"
    } catch {
        urllog "Failed to run $($step.value). Error: $_" "ERROR"
        Write-Host "`nSome steps failed. Check logs for details."
        Exit 1
    }
}
