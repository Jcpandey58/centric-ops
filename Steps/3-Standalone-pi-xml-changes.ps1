# New-Item -Path "C:\https_config" -ItemType Directory -Force

$RootFolder = "C:\HttpsUrlExpose"
$logsPath = Join-Path $RootFolder "Logs"
$StandalonePixmlLog = Join-Path $logsPath "3-Standalone-pi-xml-changes.log"

if (-not (Test-Path $StandalonePixmlLog)) {
    New-Item -ItemType File -Path $StandalonePixmlLog -Force | Out-Null
}

function WriteLog {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File $StandalonePixmlLog -Append
}

$StandalonePixmlPath = "C:\Program Files\Centric Software\C8\Wildfly\standalone\configuration\standalone-pi.xml"
# $StandalonePixmlPath = "C:\Users\jayavel.natraj\Documents\standalone-pi.xml"
$hostname = hostname

$standalonePiContent = Get-Content $StandalonePixmlPath

$updatedstandalonePiContent = @()

foreach ($line in $standalonePiContent) {
    
    if ($line -match 'name="com.centricsoftware.AppServer.WebServer"') {
		WriteLog "com.centricsoftware.AppServer.WebServer Found"
        $updatedstandalonePiContent += '        <property name="com.centricsoftware.AppServer.WebServer" value="' + "$hostname.centricsoftware.com" + '" />'
		WriteLog '"com.centricsoftware.AppServer.WebServer" value updated'
    }

    # Update HomeURL
    elseif ($line -match 'name="com.centricsoftware.AppServer.HomeURL"') {
		WriteLog "com.centricsoftware.AppServer.HomeURL Found"
        $updatedstandalonePiContent += '        <property name="com.centricsoftware.AppServer.HomeURL" value="https://' + "$hostname.centricsoftware.com/WebAccess/home.html" + '" />'
		WriteLog '"com.centricsoftware.AppServer.HomeURL" value updated'
	}

    # Update HomeExternalURL
    elseif ($line -match 'name="com.centricsoftware.AppServer.HomeExternalURL"') {
		WriteLog "com.centricsoftware.AppServer.HomeExternalURL"
        $updatedstandalonePiContent += '        <property name="com.centricsoftware.AppServer.HomeExternalURL" value="https://' + "$hostname.centricsoftware.com/WebAccess/home.html" + '" />'
		WriteLog '"com.centricsoftware.AppServer.HomeExternalURL" value updated'
	}

    <# # Update ClusterNodeAddress
    elseif ($line -match 'name="com.centricsoftware.AppServer.ClusterNodeAddress"') {
        $updatedstandalonePiContent += '        <property name="com.centricsoftware.AppServer.ClusterNodeAddress" value="' + $hostname + '" />'
    } #>

    # Update PKCS Filename
    elseif ($line -match 'name="com.centricsoftware.AppServer.PKCS.KeyStore.Filename"') {
		WriteLog "com.centricsoftware.AppServer.PKCS.KeyStore.Filename"
        $updatedstandalonePiContent += '        <property name="com.centricsoftware.AppServer.PKCS.KeyStore.Filename" value="${env.C8_AppServer_PKCS_KeyStore_Filename:C8.pfx}" />'
		WriteLog '"com.centricsoftware.AppServer.PKCS.KeyStore.Filename" value updated'
   }

    # Update PKCS KeyStore Entry
    elseif ($line -match 'name="com.centricsoftware.AppServer.PKCS.PrivateKey.KeyStoreEntry"') {
		WriteLog "com.centricsoftware.AppServer.PKCS.PrivateKey.KeyStoreEntry Found"
        $updatedstandalonePiContent += '        <property name="com.centricsoftware.AppServer.PKCS.PrivateKey.KeyStoreEntry" value="${env.C8_AppServer_PKCS_PrivateKey_KeyStoreEntry:1}" />'
		WriteLog '"com.centricsoftware.AppServer.PKCS.PrivateKey.KeyStoreEntry" value updated'
	}

    # Replace server-ssl-context self-closed line
    elseif ($line -match '<server-ssl-context .*?/>') {
		WriteLog "server-ssl-context Found"
        $updatedstandalonePiContent += '            <server-ssl-context name="LocalhostSslContext" cipher-suite-names="TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256" key-manager="LocalhostKeyManager" cipher-suite-filter="TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_DHE_RSA_WITH_AES_256_GCM_SHA384,TLS_DHE_RSA_WITH_AES_128_GCM_SHA256" />'
		WriteLog '"server-ssl-context" value updated'
	}

    # Change HTTP port 8080 to 80
    elseif ($line -match '<socket-binding name="http"') {
		WriteLog "Updtaing HTTP port"
        $updatedstandalonePiContent += $line -replace "8080", "80"
		WriteLog 'HTTP Port updated to 80'
    }

    # Change HTTPS port 8443 to 443
    elseif ($line -match '<socket-binding name="https"') {
		WriteLog "Updating socket-binding name"
        $updatedstandalonePiContent += $line -replace "8443", "443"
		WriteLog 'socket-binding name updated'
        WriteLog 'Updated HTTP and HTTPS ports'
    }
	

    <# # Uncomment HSTS filter-ref
    elseif ($line -match '<!--\s*<filter-ref name="Strict-Transport-Security"\s*/>\s*-->') {
		WriteLog "com.centricsoftware.AppServer.WebServer Found"
        $updatedstandalonePiContent += '                <filter-ref name="Strict-Transport-Security"/>'
		WriteLog '"com.centricsoftware.AppServer.WebServer" value updated'
    }

    # Uncomment HSTS response-header
    elseif ($line -match '<!--\s*<response-header name="Strict-Transport-Security".*?/>.*?-->') {
		WriteLog "com.centricsoftware.AppServer.WebServer Found"
        $updatedstandalonePiContent += '                <response-header name="Strict-Transport-Security" header-name="Strict-Transport-Security" header-value="max-age=31536000; includeSubDomains;"/>'
		WriteLog '"com.centricsoftware.AppServer.WebServer" value updated'
	} #>

    else {
        # Keep all other standalonePiContent as they are
        $updatedstandalonePiContent += $line
		
    }
}

$updatedstandalonePiContent | Set-Content $StandalonePixmlPath
WriteLog "Updated standalone-pi.xml"
