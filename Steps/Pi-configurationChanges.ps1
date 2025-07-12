. (Join-Path $PSScriptRoot "..\Common\PathSpecifier.ps1")
. (Join-Path $PSScriptRoot "..\Common\logGenerator.ps1")

$key = "com.centricsoftware.server.MessageProvider.CENTRICMESSAGEPROVIDER.CommonFromAddress"
$keyValue = "$key = noreply@centricsoftware.com"

$piConfigurationcontent = Get-Content $piConfigurationPropertiesFile

if ($piConfigurationcontent -match "^$key\s*=") {
    urllog "Message provider Key found"
    $piConfigurationcontent = $piConfigurationcontent -replace "^$key\s*=.*", $keyValue
    urllog "Updated Messge provider at pi-configuration.properties"
} 
else {
#     $piConfigurationcontent += $keyValue
        urllog "Message provider Key not found" "ERROR"
 }

$piConfigurationcontent | Set-Content $piConfigurationPropertiesFile

