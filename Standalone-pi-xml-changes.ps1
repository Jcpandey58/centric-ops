New-Item -Path "C:\https_config" -ItemType Directory -Force
$BackupLog = "C:\https_config\exposeUrl.log"

function WriteLog {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File $BackupLog -Append
}

#$xmlPath = "C:\Program Files\Centric Software\C8\Wildfly\standalone\configuration\standalone-pi-mssql.xml"
$xmlPath = "C:\Users\jayavel.natraj\Documents\standalone-pi.xml"
$hostname = $env:COMPUTERNAME

$standalonePiContent = Get-Content $xmlPath

$updatedstandalonePiContent = @()

foreach ($line in $standalonePiContent) {
    
    if ($line -match 'name="com.centricsoftware.AppServer.WebServer"') {
        $updatedstandalonePiContent += '<property name="com.centricsoftware.AppServer.WebServer" value="' + "$hostname.centricsoftware.com" + '" />'
    }

    # Update HomeURL
    elseif ($line -match 'name="com.centricsoftware.AppServer.HomeURL"') {
        $updatedstandalonePiContent += '        <property name="com.centricsoftware.AppServer.HomeURL" value="https://' + "$hostname.centricsoftware.com/WebAccess/home.html" + '" />'
    }

    # Update HomeExternalURL
    elseif ($line -match 'name="com.centricsoftware.AppServer.HomeExternalURL"') {
        $updatedstandalonePiContent += '        <property name="com.centricsoftware.AppServer.HomeExternalURL" value="https://' + "$hostname.centricsoftware.com/WebAccess/home.html" + '" />'
    }

    # Update ClusterNodeAddress
    elseif ($line -match 'name="com.centricsoftware.AppServer.ClusterNodeAddress"') {
        $updatedstandalonePiContent += '        <property name="com.centricsoftware.AppServer.ClusterNodeAddress" value="' + $hostname + '" />'
    }

    # Update PKCS Filename
    elseif ($line -match 'name="com.centricsoftware.AppServer.PKCS.KeyStore.Filename"') {
        $updatedstandalonePiContent += '        <property name="com.centricsoftware.AppServer.PKCS.KeyStore.Filename" value="${env.C8_AppServer_PKCS_KeyStore_Filename:C8.pfx}" />'
    }

    # Update PKCS KeyStore Entry
    elseif ($line -match 'name="com.centricsoftware.AppServer.PKCS.PrivateKey.KeyStoreEntry"') {
        $updatedstandalonePiContent += '        <property name="com.centricsoftware.AppServer.PKCS.PrivateKey.KeyStoreEntry" value="${env.C8_AppServer_PKCS_PrivateKey_KeyStoreEntry:1}" />'
    }

    # Replace server-ssl-context self-closed line
    elseif ($line -match '<server-ssl-context .*?/>') {
        $updatedstandalonePiContent += '            <server-ssl-context name="LocalhostSslContext" cipher-suite-names="TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256" key-manager="LocalhostKeyManager" cipher-suite-filter="TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_DHE_RSA_WITH_AES_256_GCM_SHA384,TLS_DHE_RSA_WITH_AES_128_GCM_SHA256" />'
    }

    # Change HTTP port 8080 to 80
    elseif ($line -match '<socket-binding name="http"') {
        $updatedstandalonePiContent += $line -replace "8080", "80"
    }

    # Change HTTPS port 8443 to 443
    elseif ($line -match '<socket-binding name="https"') {
        $updatedstandalonePiContent += $line -replace "8443", "443"
    }

    # Uncomment HSTS filter-ref
    elseif ($line -match '<!--\s*<filter-ref name="Strict-Transport-Security"\s*/>\s*-->') {
        $updatedstandalonePiContent += '                <filter-ref name="Strict-Transport-Security"/>'
    }

    # Uncomment HSTS response-header
    elseif ($line -match '<!--\s*<response-header name="Strict-Transport-Security".*?/>.*?-->') {
        $updatedstandalonePiContent += '                <response-header name="Strict-Transport-Security" header-name="Strict-Transport-Security" header-value="max-age=31536000; includeSubDomains;"/>'
    }

    else {
        # Keep all other standalonePiContent as they are
        $updatedstandalonePiContent += $line
    }
}

$updatedstandalonePiContent | Set-Content $xmlPath
WriteLog "Updated standalone-pi-mssql.xml using plain text method"
