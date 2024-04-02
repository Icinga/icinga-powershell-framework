function Invoke-IcingaForWindowsManagementConsoleToggleFrameworkApiChecks()
{
    if (Get-IcingaFrameworkApiChecks) {
        Disable-IcingaFrameworkApiChecks;
    } else {
        if ((Get-IcingaBackgroundDaemons).ContainsKey('Start-IcingaWindowsRESTApi') -eq $FALSE) {
            Register-IcingaBackgroundDaemon -Command 'Start-IcingaWindowsRESTApi';
            Add-IcingaRESTApiCommand -Command 'Invoke-IcingaCheck*' -Endpoint 'apichecks';
        }

        # We need to run the task renewal with our scheduled task to fix errors while using WinRM / SSH
        Start-IcingaWindowsScheduledTaskRenewCertificate;
        Enable-IcingaFrameworkApiChecks;
    }

    Restart-IcingaForWindows;
}
