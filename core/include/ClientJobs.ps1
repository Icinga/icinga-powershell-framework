$ClientJobs = New-Object -TypeName PSObject;

$ClientJobs | Add-Member -membertype NoteProperty -name 'hello_counter'    -value 0;
$ClientJobs | Add-Member -membertype NoteProperty -name 'module_scheduler' -value @( );
$ClientJobs | Add-Member -membertype NoteProperty -name 'module_output'    -value $null;

$ClientJobs | Add-Member -membertype ScriptMethod -name 'AddTicks' -value {
    param([int]$ticks);

    $this.hello_counter += $ticks;
}

$ClientJobs | Add-Member -membertype ScriptMethod -name 'WindowsHello' -value {
    param([string]$os, [string]$fqdn, [string]$version, [bool]$force);

    [hashtable]$hello = @{
        'os'      = $os;
        'fqdn'    = $fqdn;
        'version' = $version;
        'port'    = $Icinga2.Config.'tcp.socket.port';
    };

    [string]$token = $this.getAuthToken();
    if ([string]::isNullOrEmpty($token) -eq $FALSE) {
        $hello.Add(
            'modules',
            (New-Icinga-Monitoring -ListModules)
        )
    }

    if ($this.hello_counter -ge 30) {
        $this.hello_counter = 0;
    }

    if ($this.hello_counter -eq 0 -Or $force -eq $TRUE) {
        $response = $Icinga2.ClientProtocol.NewRequest(
            @('X-Windows-Hello: 1'),
            ($hello | ConvertTo-Json -Depth 2 -Compress),
            $Icinga2.Config.'checker.server.host',
            $token
        );

        $this.hello_counter += 1;

        if ($response -eq $null) {
            return $null;
        }

        try {
            $json = $response | ConvertFrom-Json;
            $Icinga2.Cache.Checker.Authenticated = $TRUE;
            $Icinga2.ClientProtocol.parseWindowsHelloResponse($json);
            return $null;
        } catch {
            $Icinga2.Log.Write(
                $Icinga2.Enums.LogState.Debug,
                $_.Exception.Message
            );
        }

        $Icinga2.Cache.Checker.Authenticated = $FALSE;

        return $response;
    }

    $this.hello_counter += 1;

    return $null;
}

$ClientJobs | Add-Member -membertype ScriptMethod -name 'getAuthToken' -value {
    [string]$token = '';
    if ($Icinga2.Cache.Checker.Authenticated -eq $TRUE -And $Icinga2.Cache.Checker.AuthToken -ne $null) {
        $token = [string]::Format('?token={0}', $Icinga2.Cache.Checker.AuthToken);
    }

    return $token;
}

$ClientJobs | Add-Member -membertype ScriptMethod -name 'ScheduleJob' -value {
    param([string]$module);

    $Icinga2.Log.Write(
        $Icinga2.Enums.LogState.Debug,
        [string]::Format(
            'Scheduling execution check for module: {0}',
            $module
        )
    );

    $this.module_scheduler += $module;
    return;

    # This would be the best, but will cause too much overhead and system load
    Start-Job -Name $module -ScriptBlock {
        return New-Icinga-Monitoring -include $args[0];
    } -ArgumentList $module;
}

$ClientJobs | Add-Member -membertype ScriptMethod -name 'ParseJobResults' -value {

    if ($this.module_scheduler.Count -eq 0) {
        return;
    }

    $moduleOutput = New-Icinga-Monitoring -Include ($this.module_scheduler) -Config $Icinga2.Cache.Checker.ModuleArguments;

    [string]$token = $this.getAuthToken();

    [string]$modules = $this.module_scheduler -Join ","

    if ([string]::isNullOrEmpty($token) -eq $TRUE) {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Debug,
            'Unable to send job results to server. No auth token is specified'
        );
        $this.FlushModuleCache($TRUE);
        return;
    }

    if ($Icinga2.ClientProtocol.GetConnectionState($Icinga2.Config.'checker.server.host') -eq $FALSE) {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Warning,
            [string]::Format(
                'Module results for "{0}" will not be send to {1}. A previous connection failed. Re-Trying in some seconds...',
                $modules,
                $Icinga2.Config.'checker.server.host'
            )
        );
        $this.FlushModuleCache($TRUE);
        return;
    }

    $this.module_output = ($moduleOutput | ConvertTo-Json -Depth 100 -Compress);

    $response = $Icinga2.ClientProtocol.NewRequest(
        @('X-Windows-Result: 1'),
        $this.module_output,
        $Icinga2.Config.'checker.server.host',
        [string]::Format(
            '{0}&results=1',
            $token
        )
    );

    $Icinga2.Log.Write(
        $Icinga2.Enums.LogState.Debug,
        [string]::Format(
            'Send modules {0} results to server. Received result: {1}',
            $modules,
            $response
        )
    );

    $this.ParseResponse($response);
    return;

    # This would be the best, but will cause too much overhead and system load
    [hashtable]$moduleOutput = @{ };

    Get-Job -State Completed | Where-Object {
        $moduleOutput.Add(
            $_.Name,
            (Receive-Job -Id $_.Id)
        );
        Remove-Job -Id $_.Id;
    };

    [string]$token = $this.getAuthToken();

    if ([string]::isNullOrEmpty($token) -eq $TRUE) {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Debug,
            'Unable to send job results to server. No auth token is specified'
        );
        return;
    }

    if ($Icinga2.ClientProtocol.GetConnectionState($Icinga2.Config.'checker.server.host') -eq $FALSE) {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Warning,
            [string]::Format(
                'Module results for "{0}" will not be send to {1}. A previous connection failed. Re-Trying in some seconds...',
                $modules,
                $Icinga2.Config.'checker.server.host'
            )
        );
        return;
    }

    $response = $Icinga2.ClientProtocol.NewRequest(
        @('X-Windows-Result: 1'),
        ($moduleOutput | ConvertTo-Json -Depth 100 -Compress),
        $Icinga2.Config.'checker.server.host',
        [string]::Format(
            '{0}&results=1',
            $token
        )
    );

    $Icinga2.Log.Write(
        $Icinga2.Enums.LogState.Debug,
        [string]::Format(
            'Send modules {0} results to server. Received result: {1}',
            ($moduleOutput | Out-String),
            $response
        )
    );
}

$ClientJobs | Add-Member -membertype ScriptMethod -name 'FlushModuleCache' -value {
    param([bool]$flush);

    if ($flush -eq $TRUE) {
        foreach($module in $this.module_scheduler) {
            $Icinga2.Utils.Modules.FlushModuleCache($module);
        }
    }

    $this.module_scheduler = @();
}

$ClientJobs | Add-Member -membertype ScriptMethod -name 'ParseResponse' -value {
    param([string]$response);

    if ([string]::IsNullOrEmpty($response) -eq $TRUE) {
        $this.FlushModuleCache($TRUE);
        return;
    }

    # Re-Try to send the informations once in case we are not authorized
    if ($response -eq '401') {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Warning,
            'Received Unauthorized (401) response. Trying to re-send results after requesting permission.'
        );
        $Icinga2.Checker.ScheduleWindowsHello($TRUE);
        [string]$token = $this.getAuthToken();
        $response = $Icinga2.ClientProtocol.NewRequest(
            @('X-Windows-Result: 1'),
            $this.module_output,
            $Icinga2.Config.'checker.server.host',
            [string]::Format(
                '{0}&results=1',
                $token
            )
        );

        if ([string]::IsNullOrEmpty($response) -eq $TRUE) {
            $this.FlushModuleCache($TRUE);
            return;
        }
    }

    try {
        $json = ConvertFrom-Json $response -ErrorAction Stop -WarningAction Stop;
    } catch {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Error,
            [string]::Format(
                'Received invalid JSON response from request: {0}',
                $response
            )
        );
        $this.FlushModuleCache($TRUE);
        return;
    }

    try {
        if ($json.response -ne $null) {
            if ($json.response -ne 200) {
                $this.FlushModuleCache($TRUE);
                return;
            }
        }
    } catch {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Error,
            [string]::Format(
                'Failed to properly parse JSON response: {0} . Exception Message: {1}',
                $response,
                $_.Exception.Message
            )
        );
        $this.FlushModuleCache($TRUE);
        return;
    }

    $this.FlushModuleCache($FALSE);
}

return $ClientJobs;