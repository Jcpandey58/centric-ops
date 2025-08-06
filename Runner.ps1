. ".\Common\PathSpecifier.ps1"
. ".\Common\logGenerator.ps1"


$controlServiceScript = ".\Common\ControlService.ps1"

$steps = @()
try{
	
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
		$steps += @{ type = "script"; value = "DB_backup.ps1" }  # Add this in your Steps folder
	}

	### 3. DB Restore (optional/placeholder)
	if ($EnableDbRestore) {
		# $steps += @{ type = "script"; value = "Restore_Database.ps1" }  # Under implementation
		log "DB Restore opted" 
	}
	if ($EnableUrlExpose) {
		
		if (-not $c8wildflyfolder) {
			Write-Host "Wildfly folder not found under $BasePath"
			log "Wildfly folder not found under $BasePath. Application may not installed in the server"
			Exit 1
		}
		$steps += @{ type = "script"; value = "Backup_Configfiles.ps1"}
		$steps += @{ type = "script"; value = "Pi-configurationChanges.ps1"}

		# Determine step4 dynamically
		$content = Get-Content $StandaloneConfBatFile
		# $line = $content | Select-String -Pattern '-Djboss.server.default.config=' -SimpleMatch
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
	# if ($EnableRestartWildFly) {
	# 	$steps += @{ type = "command"; value = "& '$controlServiceScript' -ServiceName '$($Wildflyservice.Name)' -Action 'Restart'" }
	# }
	if($EnableRestartWildFly){
		$steps += @{ type = "script"; value = "RestartWildfly.ps1" }
	}

	if($steps.Count -eq 0) {
		urllog "No steps selected in configuration." "ERROR"
		Write-Host "Please Select atleast one step in the Configuration.Properties"											
		Exit 1
	}

	### Log the planned steps
	# urllog "execution order: $($steps -join ', ')" "DEBUG"
	urllog "Execution order:" "DEBUG"
	urllog "********************************************************************************************************" "DEBUG"
	$steps | ForEach-Object { 
		urllog "$($_.type): $($_.value)" "DEBUG"
	}
	urllog "********************************************************************************************************" "DEBUG"

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
}
catch{
	urllog "$_" "Error"
	Write-Host "Script run failed with an exception"
}
Write-Host "Check logs for details..."
