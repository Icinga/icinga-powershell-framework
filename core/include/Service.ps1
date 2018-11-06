$Service = New-Object -TypeName PSObject;

$Service | Add-Member -membertype NoteProperty -name 'servicename'        -value 'IcingaWindowsModule';
$Service | Add-Member -membertype NoteProperty -name 'servicedisplayname' -value 'Icinga Windows Service';

$Service | Add-Member -membertype ScriptMethod -name 'Install' -value {
    param([string]$ServiceBinaryPath);

    if ([string]::IsNullOrEmpty($ServiceBinaryPath) -eq $TRUE) {
        return 'Please specify a valid service binary path.';
    }

    # Test if our binary does exist
    if (-Not (Test-Path $ServiceBinaryPath)) {
        return ([string]::Format(
            'Failed to install the Icinga service. The service binary specified at "{0}" does not exist.',
            $ServiceBinaryPath
        ));
    }

    $Icinga2.Log.Write(
        $Icinga2.Enums.LogState.Info,
        'Trying to install Icinga 2 Service...'
    );

    # Now add the script root which we require to include to the service
    $ServiceBinaryPath = [string]::Format(
        '{0} \"{1}\"',
         $ServiceBinaryPath,
         (Join-Path -Path $Icinga2.App.RootPath -ChildPath $Icinga2.App.ModuleName)
    );

    $result = & sc.exe create $this.servicename binPath= "$ServiceBinaryPath" DisplayName= $this.servicedisplayname start= auto;

    if ($this.HandleServiceError($LASTEXITCODE) -eq $TRUE) {
        return $FALSE;
    }

    $Icinga2.Log.Write(
        $Icinga2.Enums.LogState.Info,
        'Successfully installed the Icinga 2 Windows Service.'
    );

    return $TRUE;
}

$Service | Add-Member -membertype ScriptMethod -name 'Uninstall' -value {
    $Icinga2.Log.Write(
        $Icinga2.Enums.LogState.Info,
        'Trying to uninstall Icinga Service...'
    );

    # Stop the service before uninstalling it
    $this.Stop();

    $result = & sc.exe delete $this.servicename;

    if ($this.HandleServiceError($LASTEXITCODE) -eq $TRUE) {
        return $FALSE;
    }

    $Icinga2.Log.Write(
        $Icinga2.Enums.LogState.Info,
        'Successfully uninstalled the Icinga 2 Windows Service.'
    );

    return $TRUE;
}

$Service | Add-Member -membertype ScriptMethod -name 'Start' -value {
    $Icinga2.Log.Write(
        $Icinga2.Enums.LogState.Info,
        'Trying to start Icinga 2 Service...'
    );

    $result = & sc.exe start $this.servicename;

    if ($this.HandleServiceError($LASTEXITCODE) -eq $TRUE) {
        return;
    }

    $Icinga2.Log.Write(
        $Icinga2.Enums.LogState.Info,
        'Successfully started the Icinga 2 Service.'
    );

    $this.QueryStatus();
}

$Service | Add-Member -membertype ScriptMethod -name 'Stop' -value {
    $Icinga2.Log.Write(
        $Icinga2.Enums.LogState.Info,
        'Trying to stop Icinga 2 Service...'
    );

    $result = & sc.exe stop ($this.servicename);

    if ($this.HandleServiceError($LASTEXITCODE) -eq $TRUE) {
        return;
    }

    $Icinga2.Log.Write(
        $Icinga2.Enums.LogState.Info,
        'Successfully stopped the Icinga 2 Service.'
    );

    $this.QueryStatus();
}

$Service | Add-Member -membertype ScriptMethod -name 'Restart' -value {
    $this.Stop();
     # Wait two seconds before starting the service again
     Start-Sleep -Seconds 2;
    $this.Start();
}

$Service | Add-Member -membertype ScriptMethod -name 'QueryStatus' -value {
    $Icinga2.Log.Write(
        $Icinga2.Enums.LogState.Info,
        'Waiting to query the proper Icinga 2 Service status...'
    );
    Start-Sleep -Seconds 1;

    $this.Status();
}

$Service | Add-Member -membertype ScriptMethod -name 'Status' -value {
    $ServiceStatus = (Get-WMIObject win32_service -Filter (
        [string]::Format(
            "Name='{0}'",
            ($this.servicename)
        )
    )).State;

    if ([string]::IsNullOrEmpty($ServiceStatus) -eq $TRUE) {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Warning,
            $Icinga2.Enums.ServiceStatus.NotInstalled
        );

        return;
    }

    if ($Icinga2.Enums.ServiceStatus.ContainsKey($ServiceStatus)) {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Info,
            $Icinga2.Enums.ServiceStatus.$ServiceStatus
        );
    } else {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Info,
            [string]::Format(
                'The Icinga service status is {0}',
                $ServiceStatus
            )
        );
    }
}

$Service | Add-Member -membertype ScriptMethod -name 'HandleServiceError' -value {
    param([int]$ErrorCode);

    # Nothing to do as no error occured
    if ($ErrorCode -eq 0) {
        return $FALSE;
    }

    if ($Icinga2.Enums.SCErrorCodes.ContainsKey($ErrorCode)) {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Error,
            $Icinga2.Enums.SCErrorCodes.$ErrorCode
        );
    } else {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Error,
            ([string]::Format('Failed to execute operation for Icinga 2 Service: {0}', $result))
        );
    }

    return $TRUE;
}

return $Service;