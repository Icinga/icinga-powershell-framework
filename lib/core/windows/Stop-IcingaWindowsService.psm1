function Stop-IcingaForWindows()
{
    [string]$JeaPid = Get-IcingaJEAServicePid;

    Stop-IcingaService -Service 'icingapowershell';

    if ((Test-IcingaJEAServiceRunning -JeaPid $JeaPid)) {
        Stop-Process -Id $JeaPid -Force;
    }
}

Set-Alias -Name 'Stop-IcingaWindowsService' -Value 'Stop-IcingaForWindows';
