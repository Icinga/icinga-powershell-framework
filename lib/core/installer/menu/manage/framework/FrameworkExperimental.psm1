function Show-IcingaForWindowsManagementConsoleFrameworkExperimental()
{
    $ApiChecks = Get-IcingaFrameworkApiChecks;

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Manage Icinga for Windows experimental features. Not recommended for production!' `
        -Entries @(
            @{
                'Caption'  = ([string]::Format('Forward checks to Api: {0}', (& { if ($ApiChecks) { 'Enabled' } else { 'Disabled' } } )));
                'Command'  = 'Show-IcingaForWindowsManagementConsoleFrameworkExperimental';
                'Help'     = 'In case enabled, all check commands executed by "Exit-IcingaExecutePlugin" are forwarded to an internal REST-Api and executed from within the Icinga for Windows background daemon. Requires the Icinga for Windows background daemon and the modules "icinga-powershell-restapi" and "icinga-powershell-apichecks"';
                'Disabled' = $FALSE;
                'Action'   = @{
                    'Command'   = 'Invoke-IcingaForWindowsMangementConsoleToogleFrameworkApiChecks';
                    'Arguments' = @{ };
                }
            }
        );
}
