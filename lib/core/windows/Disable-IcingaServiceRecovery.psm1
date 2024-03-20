function Disable-IcingaServiceRecovery()
{
    if ((Get-IcingaWindowsServiceStatus -Service 'icinga2').Present) {
        $ServiceStatus = Start-IcingaProcess -Executable 'sc.exe' -Arguments 'failure icinga2 reset=0 actions=none/0/none/0/none/0';

        if ($ServiceStatus.ExitCode -ne 0) {
            Write-IcingaConsoleError -Message 'Failed to disable recover settings for service "icinga2": {0} {1}' -Objects $ServiceStatus.Message, $ServiceStatus.Error;
        } else {
            Write-IcingaConsoleNotice -Message 'Successfully disabled service recovery for service "icinga2"';
        }
    }

    if ((Get-IcingaWindowsServiceStatus -Service 'icingapowershell').Present) {
        $ServiceStatus = Start-IcingaProcess -Executable 'sc.exe' -Arguments 'failure icingapowershell reset=0 actions=none/0/none/0/none/0';

        if ($ServiceStatus.ExitCode -ne 0) {
            Write-IcingaConsoleError -Message 'Failed to disable recover settings for service "icingapowershell": {0} {1}' -Objects $ServiceStatus.Message, $ServiceStatus.Error;
        } else {
            Write-IcingaConsoleNotice -Message 'Successfully disabled service recovery for service "icingapowershell"';
        }
    }
}
