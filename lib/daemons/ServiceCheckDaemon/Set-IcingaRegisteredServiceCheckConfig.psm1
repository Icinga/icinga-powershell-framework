function Set-IcingaRegisteredServiceCheckConfig()
{
    param(
        [string]$ServiceId,
        [hashtable]$Arguments = $null,
        $Interval             = $null,
        [array]$TimeIndexes   = $null
    );

    $Services = Get-IcingaRegisteredServiceChecks;

    if ($Services.ContainsKey($ServiceId) -eq $FALSE) {
        Write-IcingaConsoleError 'Service Id was not found';
        return;
    }

    [bool]$Modified = $FALSE;
    $Path = [string]::Format('BackgroundDaemon.RegisteredServices.{0}', $ServiceId);

    if ($null -ne $Arguments) {
        Set-IcingaPowerShellConfig -Path ([string]::Format('{0}.Arguments', $Path)) -Value $Arguments;
        $Modified = $TRUE;
    }
    if ($null -ne $Interval) {
        Set-IcingaPowerShellConfig -Path ([string]::Format('{0}.Interval', $Path)) -Value $Interval;
        $Modified = $TRUE;
    }
    if ($null -ne $TimeIndexes) {
        Set-IcingaPowerShellConfig -Path ([string]::Format('{0}.TimeIndexes', $Path)) -Value $TimeIndexes;
        $Modified = $TRUE;
    }

    if ($Modified) {
        Write-IcingaConsoleNotice 'Service configuration was successfully updated';
    } else {
        Write-IcingaConsoleWarning 'No arguments were specified to update the service configuration';
    }
}
