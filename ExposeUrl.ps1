. ".\Common\PathSpecifier.ps1"
. ".\Common\logGenerator.ps1"

# === Read config from standalone.conf.bat ===
$content = Get-Content $StandaloneConfBatFile
$line = $content | Select-String -Pattern '-Djboss.server.default.config=' -SimpleMatch

if ($line) {
    $configFile = $line.Line.Split('=')[-1].Trim('"')
    urllog "Detected config file: $configFile" "DEBUG"
} else {
    urllog "Could not detect config file from $StandaloneConfBatFile" "ERROR"
    Exit 1
}
if ($configFile -eq "standalone-pi.xml") {
    $xmlfile="pi-xml-changes.ps1"
}
elseif ($configFile -eq "standalone-pi-mssql.xml") {
    $xmlfile = "pi-mssql-changes.ps1"
}
else {
    urllog "Unknown config file type: $configFile" "ERROR"
    Exit 1
}
#=== Order of Execution ===
#Plese change the order of execution below if needed or
#Please comment the line of step which is not necessary
$step1 = "DB_backup.ps1"
$step2 = "Backup_Configfiles.ps1"
$step3 = "Pi-configurationChanges.ps1"
$step4 = $xmlfile
$step5 = "BatFileChanges.ps1"   
$step6 = "pfxFileReplacement.ps1"
$step7 = "cmd.ps1"
$step8 = "RestartWildfly.ps1"


#=== List of step scripts ===
$steps = @(
    $step1,
    $step2,
    $step3,
    $step4,
    $step5,
    $step6,
    $step7,
    $step8
)

$steps = $steps | Where-Object { $_ -and $_.Trim() -ne "" }

urllog "execution order: $($steps -join ', ')" "DEBUG"
# === Run each step ===
foreach ($script in $steps) {
    urllog "Running: $script"
     try {
        & ".\Steps\$script"
        urllog "$script finished"
    }
    catch {
        urllog "Failed to run $script. Error: $_" "ERROR"
    }
}

Write-Host "All steps completed`nURL exposed"
