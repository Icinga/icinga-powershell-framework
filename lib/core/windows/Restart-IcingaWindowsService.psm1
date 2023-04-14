function Restart-IcingaForWindows()
{
    param (
        [switch]$Force = $FALSE
    );

    if ($Global:Icinga.Protected.ServiceRestartLock -And $Force -eq $FALSE) {
        return;
    }

    [string]$JeaPid = Get-IcingaJEAServicePid;

    Stop-IcingaService -Service 'icingapowershell' -Force:$Force;

    if ((Test-IcingaJEAServiceRunning -JeaPid $JeaPid)) {
        Stop-IcingaJEAProcess -JeaPid $JeaPid;
    }

    Restart-IcingaService -Service 'icingapowershell' -Force:$Force;
}

Set-Alias -Name 'Restart-IcingaWindowsService' -Value 'Restart-IcingaForWindows';
