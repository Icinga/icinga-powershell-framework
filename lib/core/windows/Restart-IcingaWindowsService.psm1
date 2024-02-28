function Restart-IcingaWindowsService()
{
    [string]$JeaPid = Get-IcingaJEAServicePid;

    Stop-IcingaService -Service 'icingapowershell';

    if ((Test-IcingaJEAServiceRunning -JeaPid $JeaPid)) {
        Stop-IcingaJEAProcess -JeaPid $JeaPid;
    }

    Restart-IcingaService -Service 'icingapowershell';
}
