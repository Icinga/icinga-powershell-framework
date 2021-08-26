function Show-IcingaForWindowsManagementConsoleManageIcingaRepositories()
{
    Show-IcingaForWindowsInstallerMenu `
        -Header 'Manage Icinga for Windows Repositories:' `
        -Entries @(
            @{
                'Caption' = 'Set Icinga Repository "Icinga Stable"';
                'Command' = 'Show-IcingaForWindowsManagementConsoleSetIcingaStableRepositories';
                'Help'    = 'Allows to set the repository URL for the "Icinga Stable" repository and will override it, if it already exist';
            },
            @{
                'Caption' = 'Set Icinga Repository "Icinga Snapshot"';
                'Command' = 'Show-IcingaForWindowsManagementConsoleSetIcingaSnapshotRepositories';
                'Help'    = 'Allows to set the repository URL for the "Icinga Snapshot" repository and will override it, if it already exist';
            },
            @{
                'Caption' = 'Show Icinga Repository list';
                'Command' = 'Show-IcingaForWindowsManagementConsoleIcingaRepositoriesList';
                'Help'    = 'Shows a list of all defined Icinga Repositories on this machine';
            },
            @{
                'Caption' = 'Move Icinga Repository to top';
                'Command' = 'Show-IcingaForWindowsManagementConsolePushIcingaRepository';
                'Help'    = 'Allows you to move certain repositories on the system to the top of the list, which will then be applied first';
            },
            @{
                'Caption' = 'Move Icinga Repository to bottom';
                'Command' = 'Show-IcingaForWindowsManagementConsolePopIcingaRepository';
                'Help'    = 'Allows you to move certain repositories on the system to the bottom of the list, which will then be applied last';
            },
            @{
                'Caption' = 'Enable Icinga Repository';
                'Command' = 'Show-IcingaForWindowsManagementConsoleEnableIcingaRepository';
                'Help'    = 'Allows you to enable certain repositories on the system';
            },
            @{
                'Caption' = 'Disable Icinga Repository';
                'Command' = 'Show-IcingaForWindowsManagementConsoleDisableIcingaRepository';
                'Help'    = 'Allows you to disable certain repositories on the system';
            },
            @{
                'Caption' = 'Remove Icinga Repository';
                'Command' = 'Show-IcingaForWindowsManagementConsoleRemoveIcingaRepository';
                'Help'    = 'Allows you to remove certain repositories from the system';
            }
        );
}
