function Show-IcingaForWindowsManagementConsoleManageBackgroundDaemons()
{
    Show-IcingaForWindowsInstallerMenu `
        -Header 'Manage the Icinga for Windows background daemons:' `
        -Entries @(
            @{
                'Caption'  = 'Register background daemon';
                'Command'  = 'Show-IcingaForWindowsManagementConsoleRegisterBackgroundDaemons';
                'Help'     = 'Allows you to register a new background daemon for Icinga for Windows';
                'Disabled' = $FALSE;
            },
            @{
                'Caption'  = 'Unregister background daemon';
                'Command'  = 'Show-IcingaForWindowsManagementConsoleUnregisterBackgroundDaemons';
                'Help'     = 'Remove registered Icinga for Windows background daemons';
                'Disabled' = $FALSE;
            }
        );
}
