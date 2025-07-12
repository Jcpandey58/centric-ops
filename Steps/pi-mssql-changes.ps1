. ".\PathSpecifier.ps1"

Write-Host "Updating standalone-pi-mssql.xml"
$hostname = hostname
$standalonePiContent = Get-Content $StandalonePimssqlxmlFile

$updatedstandalonePiContent = @()

foreach ($line in $standalonePiContent) {
    
    if ($line -match 'name="com.centricsoftware.AppServer.WebServer"') {
		urllog "com.centricsoftware.AppServer.WebServer Found"
        $updatedstandalonePiContent += '        <property name="com.centricsoftware.AppServer.WebServer" value="' + "$hostname.centricsoftware.com" + '" />'
		urllog '"com.centricsoftware.AppServer.WebServer" value updated'
    }

    # Update HomeURL
    elseif ($line -match 'name="com.centricsoftware.AppServer.HomeURL"') {
		urllog "com.centricsoftware.AppServer.HomeURL Found"
        $updatedstandalonePiContent += '        <property name="com.centricsoftware.AppServer.HomeURL" value="https://' + "$hostname.centricsoftware.com/WebAccess/home.html" + '" />'
		urllog '"com.centricsoftware.AppServer.HomeURL" value updated'
	}

    # Update HomeExternalURL
    elseif ($line -match 'name="com.centricsoftware.AppServer.HomeExternalURL"') {
		urllog "com.centricsoftware.AppServer.HomeExternalURL Found"
        $updatedstandalonePiContent += '        <property name="com.centricsoftware.AppServer.HomeExternalURL" value="https://' + "$hostname.centricsoftware.com/WebAccess/home.html" + '" />'
		urllog '"com.centricsoftware.AppServer.HomeExternalURL" value updated'
	}

    <# # Update ClusterNodeAddress
    elseif ($line -match 'name="com.centricsoftware.AppServer.ClusterNodeAddress"') {
        $updatedstandalonePiContent += '        <property name="com.centricsoftware.AppServer.ClusterNodeAddress" value="' + $hostname + '" />'
    } #>

    # Update PKCS Filename
    elseif ($line -match 'name="com.centricsoftware.AppServer.PKCS.KeyStore.Filename"') {
		urllog "com.centricsoftware.AppServer.PKCS.KeyStore.Filename found"
        $updatedstandalonePiContent += '        <property name="com.centricsoftware.AppServer.PKCS.KeyStore.Filename" value="${env.C8_AppServer_PKCS_KeyStore_Filename:C8.pfx}" />'
		urllog '"com.centricsoftware.AppServer.PKCS.KeyStore.Filename" value updated'
   }

    # Update PKCS KeyStore Entry
    elseif ($line -match 'name="com.centricsoftware.AppServer.PKCS.PrivateKey.KeyStoreEntry"') {
		urllog "com.centricsoftware.AppServer.PKCS.PrivateKey.KeyStoreEntry Found"
        $updatedstandalonePiContent += '        <property name="com.centricsoftware.AppServer.PKCS.PrivateKey.KeyStoreEntry" value="${env.C8_AppServer_PKCS_PrivateKey_KeyStoreEntry:1}" />'
		urllog '"com.centricsoftware.AppServer.PKCS.PrivateKey.KeyStoreEntry" value updated'
	}

    # Replace server-ssl-context self-closed line
    elseif ($line -match '<server-ssl-context .*?/>') {
		urllog "server-ssl-context Found"
        $updatedstandalonePiContent += '            <server-ssl-context name="LocalhostSslContext" cipher-suite-names="TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256" key-manager="LocalhostKeyManager" cipher-suite-filter="TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_DHE_RSA_WITH_AES_256_GCM_SHA384,TLS_DHE_RSA_WITH_AES_128_GCM_SHA256" />'
		urllog '"server-ssl-context" value updated'
	}

    # Change HTTP port 8080 to 80
    elseif ($line -match '<socket-binding name="http"') {
		urllog "Updtaing HTTP port"
        $updatedstandalonePiContent += $line -replace "8080", "80"
		urllog 'HTTP Port updated to 80'
    }

    # Change HTTPS port 8443 to 443
    elseif ($line -match '<socket-binding name="https"') {
		urllog "Updating socket-binding name"
        $updatedstandalonePiContent += $line -replace "8443", "443"
		urllog 'socket-binding name updated'
        urllog 'Updated HTTP and HTTPS ports'
    }
	

    <# # Uncomment HSTS filter-ref
    elseif ($line -match '<!--\s*<filter-ref name="Strict-Transport-Security"\s*/>\s*-->') {
		urllog "com.centricsoftware.AppServer.WebServer Found"
        $updatedstandalonePiContent += '                <filter-ref name="Strict-Transport-Security"/>'
		urllog '"com.centricsoftware.AppServer.WebServer" value updated'
    }

    # Uncomment HSTS response-header
    elseif ($line -match '<!--\s*<response-header name="Strict-Transport-Security".*?/>.*?-->') {
		urllog "com.centricsoftware.AppServer.WebServer Found"
        $updatedstandalonePiContent += '                <response-header name="Strict-Transport-Security" header-name="Strict-Transport-Security" header-value="max-age=31536000; includeSubDomains;"/>'
		urllog '"com.centricsoftware.AppServer.WebServer" value updated'
	} #>

    else {
        # Keep all other standalonePiContent as they are
        $updatedstandalonePiContent += $line
		
    }
}

$updatedstandalonePiContent | Set-Content $StandalonePimssqlxmlFile
Write-Host "Completed"
urllog "Completed Updating standalone-pi-mssql.xml"
