function Show-IcingaForWindowsManagementConsoleManageIcingaForWindowsFeatures()
{
    $FrameworkDebug = Get-IcingaFrameworkDebugMode;
    $ApiChecks      = Get-IcingaFrameworkApiChecks;

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Manage Icinga for Windows features:' `
        -Entries @(
            @{
                'Caption'  = ([string]::Format('Api-Check Forwarder: {0}', (& { if ($ApiChecks) { 'Enabled' } else { 'Disabled' } } )));
                'Command'  = 'Show-IcingaForWindowsManagementConsoleManageIcingaForWindowsFeatures';
                'Help'     = 'In case enabled, all check commands executed by "Exit-IcingaExecutePlugin" (Icinga default) are forwarded to an internal REST-Api and executed from within the Icinga for Windows background daemon. Requires the Icinga for Windows background daemon';
                'Disabled' = $FALSE;
                'Action'   = @{
                    'Command'   = 'Invoke-IcingaForWindowsManagementConsoleToggleFrameworkApiChecks';
                    'Arguments' = @{ };
                }
            },
            @{
                'Caption'  = ([string]::Format('Debug Mode: {0}', (& { if ($FrameworkDebug) { 'Enabled' } else { 'Disabled' } } )));
                'Command'  = 'Show-IcingaForWindowsManagementConsoleManageIcingaForWindowsFeatures';
                'Help'     = 'Disable or enable the Icinga for Windows debug mode';
                'Disabled' = $FALSE;
                'Action'   = @{
                    'Command' = 'Invoke-IcingaForWindowsManagementConsoleToggleFrameworkDebug';
                }
            },
            @{
                'Caption'  = 'Experimental';
                'Command'  = 'Show-IcingaForWindowsManagementConsoleFrameworkExperimental';
                'Help'     = 'Allows you to manage experimental features for Icinga for Windows';
                'Disabled' = $FALSE
            }
        );
}
