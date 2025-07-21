. ".\Common\PathSpecifier.ps1"
. ".\Common\logGenerator.ps1"

$steps = @()
try{
	
	if($EnableStopPDF){
		$Stoppdf = & ".\Common\ControlService.ps1" -ServiceName $PDFservice -Action "Stop"
		$steps += $Stoppdf
	}
	
	if($EnableStopImage){
		$Stopimage = & ".\Common\ControlService.ps1" -ServiceName $Imageservice -Action "Stop"
		$steps += $Stopimage
	}
	
	if($EnableStopWildFly){
		$stopwildfly = & ".\Common\ControlService.ps1" -ServiceName $Wildflyservice -Action "Stop"
		$steps += $stopwildfly
	}
	
	if ($EnableDbBackup) {
		$steps += "DB_backup.ps1"
	}

	if ($EnableUrlExpose) {
		
		if (-not $c8wildflyfolder) {
			Write-Host "Wildfly folder not found under $BasePath"
			Exit 1
		}
		$steps += "Backup_Configfiles.ps1"
		$steps += "Pi-configurationChanges.ps1"

		# Determine step4 dynamically
		$content = Get-Content $StandaloneConfBatFile
		$line = $content | Select-String -Pattern '-Djboss.server.default.config=' -SimpleMatch						   

		if ($line) {
			$configFile = $line.Line.Split('=')[-1].Trim('"')
			urllog "Detected config file: $configFile" "DEBUG"
		} else {
			urllog "Could not detect config file from $StandaloneConfBatFile" "ERROR"
			Exit 1
		}

		switch ($configFile) {
			
			"standalone-pi.xml" 	{ $steps += "pi-xml-changes.ps1" }
			"standalone-pi-mssql.xml" { $steps += "pi-mssql-changes.ps1" }
			
			default {
				urllog "Unknown config file type: $configFile" "ERROR"
				Exit 1	  
			}
		}

		$steps += "BatFileChanges.ps1"
		$steps += "pfxFileReplacement.ps1"
		$steps += "cmd.ps1"
		$steps += "RestartWildfly.ps1"
	}
	
	if($EnableRestartWildFly){
		$steps += "RestartWildfly.ps1"
	}


	if($EnableStartWildFly){
		$startWildfly = & ".\Common\ControlService.ps1" -ServiceName $Wildflyservice -Action "Start"
		$steps += $startWildfly
	}
	if($EnableStartPDF){
		$startpdf = & ".\Common\ControlService.ps1" -ServiceName $PDFservice -Action "Start"
		$steps += $startpdf
	}
	if($EnableStartImage){
		$startimage = & ".\Common\ControlService.ps1" -ServiceName $Imageservice -Action "Start"
		$steps += $startimage
	}

	if($EnableRestartImage){
		$restartimage = & ".\Common\ControlService.ps1" -ServiceName $Imageservice -Action "Restart"
		$steps += $restartimage
	}
	if($EnableRestartPDF){
		$restartpdf = & ".\Common\ControlService.ps1" -ServiceName $Imageservice -Action "Restart"
		$steps += $restartpdf
	}

	if($steps.Count -eq 0) {
		urllog "No steps selected in configuration." "ERROR"												
		Exit 1
	}

	urllog "execution order: $($steps -join ', ')" "DEBUG"
					   
	foreach ($script in $steps) {
		urllog "Running: $script"
		try {
			& ".\Steps\$script"
			urllog "$script finished"
		 
		} catch {
			urllog "Failed to run $script. Error: $_" "ERROR"
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
