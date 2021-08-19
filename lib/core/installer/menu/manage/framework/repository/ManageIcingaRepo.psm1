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
            }
        );
}
