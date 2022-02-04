function Show-IcingaForWindowsManagementConsoleComponentManager()
{
    Show-IcingaForWindowsInstallerMenu `
        -Header 'Choose what you want to do with components' `
        @{
            'Caption' = 'Install';
            'Command' = 'Show-IcingaForWindowsMenuInstallComponents';
            'Help'    = 'Allows you to install new components for Icinga for Windows from your repositories.';
        },
        @{
            'Caption' = 'Install from Snapshot';
            'Command' = 'Show-IcingaForWindowsMenuInstallComponentsSnapshot';
            'Help'    = 'Allows you to install new components for Icinga for Windows from your repositories.';
        },
        @{
            'Caption' = 'Update';
            'Command' = 'Show-IcingaForWindowsMenuUpdateComponents';
            'Help'    = 'Allows you to modify your current Icinga for Windows installation.';
        },
        @{
            'Caption' = 'Update from Snapshot';
            'Command' = 'Show-IcingaForWindowsMenuUpdateComponentsSnapshot';
            'Help'    = 'Allows you to modify your current Icinga for Windows installation.';
        },
        @{
            'Caption' = 'Remove';
            'Command' = 'Show-IcingaForWindowsMenuRemoveComponents';
            'Help'    = 'Allows you to modify your current Icinga for Windows installation.';
        }
}
