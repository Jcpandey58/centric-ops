$logPath = "C:\Log.txt"

function Log {
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$time - $args" | Out-File $logPath -Append
}

# Step 1: Update pi-configuration.properties
$piFile = "C:\Program Files\Centric Software\C8\Wildfly\standalone\configuration\pi-configuration.properties"
$emailKey = "com.centricsoftware.server.MessageProvider.CENTRICMESSAGEPROVIDER.CommonFromAddress"
$emailValue = "$emailKey = noreply@centricsoftware.com"
$piContent = Get-Content $piFile

if ($piContent -match "^$emailKey\s*=") {
    $piContent = $piContent -replace "^$emailKey\s*=.*", $emailValue
} else {
    $piContent += $emailValue
}
$piContent | Set-Content $piFile
Log "✅ Updated email in pi-configuration.properties"

# Step 2: Update XML file values
$xmlFile = "C:\Program Files\Centric Software\C8\Wildfly\standalone\configuration\standalone-pi-mssql.xml"
[xml]$xml = Get-Content $xmlFile
$host = $env:COMPUTERNAME

# Set simple values
$props = $xml.SelectNodes("//system-properties/property")
foreach ($p in $props) {
    switch ($p.name) {
        "com.centricsoftware.AppServer.ClusterNodeAddress"        { $p.value = $host }
        "com.centricsoftware.AppServer.WebServer"                 { $p.value = "$host.centricsoftware.com" }
        "com.centricsoftware.AppServer.HomeURL"                   { $p.value = "https://$host.centricsoftware.com/WebAccess/home.html" }
        "com.centricsoftware.AppServer.HomeExternalURL"           { $p.value = "https://$host.centricsoftware.com/WebAccess/home.html" }
        "com.centricsoftware.AppServer.PKCS.KeyStore.Filename"    { $p.value = '${env.C8_AppServer_PKCS_KeyStore_Filename:C8.pfx}' }
        "com.centricsoftware.AppServer.PKCS.PrivateKey.KeyStoreEntry" { $p.value = '${env.C8_AppServer_PKCS_PrivateKey_KeyStoreEntry:1}' }
    }
}
$xml.Save($xmlFile)
Log "✅ Updated XML system-properties"

# Step 3: Replace SSL context
(Get-Content $xmlFile -Raw) -replace '<server-ssl-context.*?/>',
'<server-ssl-context name="LocalhostSslContext" cipher-suite-names="TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256" key-manager="LocalhostKeyManager" cipher-suite-filter="TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_DHE_RSA_WITH_AES_256_GCM_SHA384,TLS_DHE_RSA_WITH_AES_128_GCM_SHA256" />' | Set-Content $xmlFile
Log "✅ Replaced SSL context"

# Step 4: Update port numbers
$xml = [xml](Get-Content $xmlFile)
$sockets = $xml.SelectNodes("//socket-binding")
foreach ($s in $sockets) {
    if ($s.name -eq "http")  { $s.port = '${jboss.http.port:80}' }
    if ($s.name -eq "https") { $s.port = '${jboss.https.port:443}' }
}
$xml.Save($xmlFile)
Log "✅ Updated HTTP and HTTPS ports"

# Step 5: Uncomment HSTS/HTST
(Get-Content $xmlFile) `
-replace '<!--\s*<filter-ref name="Strict-Transport-Security"\s*/>\s*-->', '<filter-ref name="Strict-Transport-Security"/>' `
-replace '<!--\s*<response-header name="Strict-Transport-Security".*?/>.*?-->', '<response-header name="Strict-Transport-Security" header-name="Strict-Transport-Security" header-value="max-age=31536000; includeSubDomains;"/>' `
| Set-Content $xmlFile
Log "✅ Enabled HSTS"

# Step 6: Add Java path to system path if not exists
$javaPath = "%JAVA_HOME%\bin"
$sysPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($sysPath -notlike "*$javaPath*") {
    [Environment]::SetEnvironmentVariable("Path", "$sysPath;$javaPath", "Machine")
    Log "✅ Java path added to system environment"
} else {
    Log "ℹ️ Java path already present"
}

# Step 7: Add JAVA_OPTS in standalone.conf.bat
$confFile = "C:\Program Files\Centric Software\C8\Wildfly\bin\standalone.conf.bat"
$batLine = 'set "JAVA_OPTS=%JAVA_OPTS% -Djdk.tls.ephemeralDHKeySize=2048 -Djdk.tls.rejectClientInitiatedRenegotiation=true"'

if (-not (Select-String -Path $confFile -Pattern 'rejectClientInitiatedRenegotiation')) {
    Add-Content $confFile "`r`n$batLine"
    Log "✅ Added JAVA_OPTS to standalone.conf.bat"
} else {
    Log "ℹ️ JAVA_OPTS already added"
}

Log "🎉 All done!"
