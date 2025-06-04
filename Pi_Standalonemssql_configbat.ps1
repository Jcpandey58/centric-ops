# Define log path
$logPath = "C:\Log.txt"

# Simple logging function
function Write-Log {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -FilePath $logPath -Append
}

# Step 1: Update pi-configuration.properties
$piConfigFile = "C:\Program Files\Centric Software\C8\Wildfly\standalone\configuration\pi-configuration.properties"
$key = "com.centricsoftware.server.MessageProvider.CENTRICMESSAGEPROVIDER.CommonFromAddress"
$value = "noreply@centricsoftware.com"

$content = Get-Content $piConfigFile
$found = $false

for ($i = 0; $i -lt $content.Length; $i++) {
    if ($content[$i] -match "^$key\s*=") {
        $content[$i] = "$key = $value"
        $found = $true
    }
}

if (-not $found) {
    $content += "$key = $value"
}

$content | Set-Content $piConfigFile
Write-Log "Updated email address in pi-configuration.properties"

# Step 2: Update XML properties in standalone-pi-mssql.xml
$xmlPath = "C:\Program Files\Centric Software\C8\Wildfly\standalone\configuration\standalone-pi-mssql.xml"
[xml]$xml = Get-Content $xmlPath

$host = hostname
$systemProps = $xml.SelectSingleNode("//ns:system-properties", @{ "ns" = "urn:jboss:domain:7.0" })

# Update values
$updates = @{
    "com.centricsoftware.AppServer.ClusterNodeAddress"       = $host
    "com.centricsoftware.AppServer.WebServer"                = "$host.centricsoftware.com"
    "com.centricsoftware.AppServer.HomeURL"                  = "https://$host.centricsoftware.com/WebAccess/home.html"
    "com.centricsoftware.AppServer.HomeExternalURL"          = "https://$host.centricsoftware.com/WebAccess/home.html"
    "com.centricsoftware.AppServer.PKCS.KeyStore.Filename"   = '${env.C8_AppServer_PKCS_KeyStore_Filename:C8.pfx}'
    "com.centricsoftware.AppServer.PKCS.PrivateKey.KeyStoreEntry" = '${env.C8_AppServer_PKCS_PrivateKey_KeyStoreEntry:1}'
}

foreach ($name in $updates.Keys) {
    $node = $systemProps.SelectSingleNode("ns:property[@name='$name']", $systemProps.NamespaceManager)
    if ($node) {
        $node.SetAttribute("value", $updates[$name])
    }
}

$xml.Save($xmlPath)
Write-Log "Updated system-properties in XML"

# Step 3: Replace server-ssl-context
(Get-Content $xmlPath -Raw) -replace `
    '<server-ssl-context name="LocalhostSslContext" key-manager="LocalhostKeyManager" />', `
    '<server-ssl-context name="LocalhostSslContext" cipher-suite-names="TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256" key-manager="LocalhostKeyManager" cipher-suite-filter="TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_DHE_RSA_WITH_AES_256_GCM_SHA384,TLS_DHE_RSA_WITH_AES_128_GCM_SHA256" />' `
    | Set-Content $xmlPath

Write-Log "Updated server-ssl-context configuration"

# Step 4: Update http/https ports
$socketGroup = $xml.SelectSingleNode("//ns:socket-binding-group", @{ "ns" = "urn:jboss:domain:7.0" })

$portUpdates = @{
    "http"  = '${jboss.http.port:80}'
    "https" = '${jboss.https.port:443}'
}

foreach ($name in $portUpdates.Keys) {
    $binding = $socketGroup.SelectSingleNode("ns:socket-binding[@name='$name']", $socketGroup.NamespaceManager)
    if ($binding) {
        $binding.SetAttribute("port", $portUpdates[$name])
    }
}

$xml.Save($xmlPath)
Write-Log "Updated HTTP and HTTPS ports"

# Step 5: Uncomment HSTS headers
$lines = Get-Content $xmlPath
$lines = $lines -replace '<!--\s*<filter-ref name="Strict-Transport-Security"\s*/>\s*-->', '<filter-ref name="Strict-Transport-Security"/>'
$lines = $lines -replace '<!--\s*<response-header name="Strict-Transport-Security".*?/>.*?-->', '<response-header name="Strict-Transport-Security" header-name="Strict-Transport-Security" header-value="max-age=31536000; includeSubDomains;"/>'
$lines | Set-Content $xmlPath
Write-Log "Uncommented HSTS headers"

# Step 6: Add Java path to system environment variable
$javaPath = "%JAVA_HOME%\bin"
$current = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($current -notlike "*$javaPath*") {
    [Environment]::SetEnvironmentVariable("Path", "$current;$javaPath", "Machine")
    Write-Log "Added Java path to environment variable"
} else {
    Write-Log "Java path already exists in environment variable"
}

# Step 7: Append JAVA_OPTS in standalone.conf.bat
$confPath = "C:\Program Files\Centric Software\C8\Wildfly\bin\standalone.conf.bat"
$insertAfter = 'rem set "DEBUG_PORT=8787"'
$newLine = 'set "JAVA_OPTS=%JAVA_OPTS% -Djdk.tls.ephemeralDHKeySize=2048 -Djdk.tls.rejectClientInitiatedRenegotiation=true"'

$content = Get-Content $confPath
$output = @()

foreach ($line in $content) {
    $output += $line
    if ($line -eq $insertAfter) {
        $output += $newLine
    }
}

$output | Set-Content $confPath
Write-Log "Added JAVA_OPTS in standalone.conf.bat"

Write-Log "✅ Pi and Standalone configuration completed."
