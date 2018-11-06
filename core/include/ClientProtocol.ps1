$ClientProtocol = New-Object -TypeName PSObject;

$ClientProtocol | Add-Member -membertype NoteProperty -name 'fqdn' -value '';

$ClientProtocol | Add-Member -membertype ScriptMethod -name 'setFQDN' -value {
    param([string]$fqdn);

    $this.fqdn = $fqdn;
}

$ClientProtocol | Add-Member -membertype ScriptMethod -name 'SetConnectionState' -value {
    param([string]$remoteAddress, [bool]$reachable);

    if ($Icinga2.Cache.Checker.RemoteServices -eq $null) {
        $Icinga2.Cache.Checker.RemoteServices = @{ };
    }

    if ($Icinga2.Cache.Checker.RemoteServices.ContainsKey($remoteAddress) -eq $FALSE) {
        $Icinga2.Cache.Checker.RemoteServices.Add($remoteAddress, $reachable);
        return;
    }

    $Icinga2.Cache.Checker.RemoteServices[$remoteAddress] = $reachable;
}

$ClientProtocol | Add-Member -membertype ScriptMethod -name 'GetConnectionState' -value {
    param([string]$remoteAddress);

    if ($Icinga2.Cache.Checker.RemoteServices.ContainsKey($remoteAddress) -eq $FALSE) {
        return $TRUE;
    }

    return $Icinga2.Cache.Checker.RemoteServices[$remoteAddress];
}

$ClientProtocol | Add-Member -membertype ScriptMethod -name 'NewRequest' -value {
    param([array]$headers, [string]$content, [string]$remoteAddress, [string]$url);

    $url = [string]::Format(
        '{0}{1}',
        $remoteAddress,
        $url
    );

    $httpRequest = [System.Net.HttpWebRequest]::Create(
        $url
    );
    $httpRequest.Method = 'POST';
    $httpRequest.Accept = 'application/json';
    $httpRequest.ContentType = 'application/json';
    $httpRequest.Headers.Add(
        [string]::Format(
            'X-Windows-CheckResult: {0}',
            $this.fqdn
        )
    );

    # Add possible custom header
    foreach ($header in $headers) {
        $httpRequest.Headers.Add($header);
    }
    $httpRequest.TimeOut = 60000;

    # If we are using self-signed certificates for example, the HTTP request will
    # fail caused by the SSL certificate. With this we can allow even faulty
    # certificates. This should be used with caution
    if (-Not $Icinga2.Config.'checker.ssl.verify') {
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
    }

    try {
        # Only send data in case we want to send some data
        if ($content -ne '') {
            $transmitBytes = [System.Text.Encoding]::UTF8.GetBytes($content);
            $httpRequest.ContentLength = $transmitBytes.Length;
            [System.IO.Stream]$httpOutput = [System.IO.Stream]$httpRequest.GetRequestStream()
            $httpOutput.Write($transmitBytes, 0, $transmitBytes.Length)
            $httpOutput.Close()
        }
    } catch [System.Net.WebException] {
        $this.SetConnectionState($remoteAddress, $FALSE);

        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Exception,
            [string]::Format('Exception while trying to connect to "{0}". Possible a connection error. Message: {1}',
                $url,
                $_.Exception.Message
            )
        );
        return $null;
    } catch {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Exception,
           $_.Exception.Message
        );
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Exception,
           $_.Exception.StackTrace
        );
        return $null;
    }

    try {

        $this.SetConnectionState($remoteAddress, $TRUE);
        return $this.readResponseStream($httpRequest.GetResponse());

    } catch [System.Net.WebException] {
        # Print an exception message and the possible body in case we received one
        # to make troubleshooting easier
        [string]$errorResponse = $this.readResponseStream($_.Exception.Response);
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Debug,
            $_.Exception.Message
        );
        if ($errorResponse -ne '') {
            $Icinga2.Log.Write(
                $Icinga2.Enums.LogState.Debug,
                $errorResponse
            );
        }

        $exceptionMessage = $_.Exception.Response;
        if ($exceptionMessage.StatusCode) {
            return [int][System.Net.HttpStatusCode]$exceptionMessage.StatusCode;
        } else {
            return 900;
        }
    }

    return $null;
}

$ClientProtocol | Add-Member -membertype ScriptMethod -name 'readResponseStream' -value {
    param([System.Object]$response);

    try {
        if ($response) {
            $responseStream = $response.getResponseStream();
            $streamReader = New-Object IO.StreamReader($responseStream);
            $result = $streamReader.ReadToEnd();
            $response.close()
            $streamReader.close()
    
            return $result;
        }
    
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Exception,
            'The received response from the remote server is NULL. This might be caused by SSL errors or wrong Webserver configuration.'
        );
    } catch {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Exception,
            $_.Exception.Message
        );
    }

    return $null;
}

$ClientProtocol | Add-Member -membertype ScriptMethod -name 'parseWindowsHelloResponse' -value {
    param($json);

    $Icinga2.Log.Write(
        $Icinga2.Enums.LogState.Debug,
        [string]::Format(
            'Remote Server Output: {0}',
            $json
        )
    );

    $Icinga2.Cache.Checker.AuthToken = $json.token;
    if ($Icinga2.Cache.Checker.ModuleConfig -eq $null) {
        $Icinga2.Cache.Checker.ModuleConfig = @{};
    }

    $Icinga2.Cache.Checker.ModuleArguments = $json.module_arguments;

    [hashtable]$activeModules = @{};

    foreach ($module in $json.modules) {
        if ($Icinga2.Cache.Checker.ModuleConfig.ContainsKey($module.name)) {
            $Icinga2.Cache.Checker.ModuleConfig[$module.name] = $module.check_interval;
        } else {
            $Icinga2.Cache.Checker.ModuleConfig.Add($module.name, $module.check_interval);
        }
        $activeModules.Add($module.name, $TRUE);

        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Debug,
            [string]::Format(
                'Adding module {0} with check intervall {1}',
                $module.name,
                $module.check_interval
            )
        );
    }

    # We might have disabled some modules. Lets handle this by setting the
    # execution timer to -1
    foreach ($module in $Icinga2.Cache.Checker.ModuleConfig.Keys) {
        if ($activeModules.ContainsKey($module) -eq $FALSE) {
            $activeModules.Add($module, $FALSE);
        }
    }

    # We require a second loop to ensure we won't crash because of a changed hashtable
    foreach($module in $activeModules.Keys) {
        if ($activeModules[$module] -eq $FALSE) {
            if ($Icinga2.Cache.Checker.ModuleConfig.ContainsKey($module)) {
                $Icinga2.Cache.Checker.ModuleConfig.Remove($module);
                $Icinga2.Log.Write(
                    $Icinga2.Enums.LogState.Debug,
                    [string]::Format(
                        'Disabling module {0}',
                        $module
                    )
                );
            }
        }
    }
}

return $ClientProtocol;