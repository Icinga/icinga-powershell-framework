function Show-IcingaForWindowsInstallerMenuFinishInstaller()
{
    Show-IcingaForWindowsInstallerMenu `
        -Header 'How you do want to proceed:' `
        -Entries @(
            @{
                'Caption'  = 'Start installation';
                'Command'  = 'Start-IcingaForWindowsInstallation';
                'Help'     = 'Apply the just configured configuration and install components as selected';
                'Disabled' = (-Not ($global:Icinga.InstallWizard.AdminShell));
                'Action'   = @{
                    'Command' = 'Clear-IcingaForWindowsManagementConsolePaginationCache';
                }
            },
            @{
                'Caption' = 'Export answer file';
                'Command' = 'Show-IcingaForWindowsManagementConsoleInstallationFileExport';
                'Help'    = 'Allows you to export a JSON file containing all settings configured during this step and use it on another system';
            },
            @{
                'Caption' = 'Print installation command';
                'Command' = 'Show-IcingaForWindowsManagementConsoleInstallationConfigString';
                'Help'    = 'Allows you to export a simple configuration command you can run on another system. Similar to the "Export answer file" option, but does not require to distribute files';
            },
            @{
                'Caption' = 'Save current configuration and go to main menu';
                'Command' = 'Install-Icinga';
                'Help'    = 'Keep the current configuration as "swap" and exit to the main menu';
                'Action'  = @{
                    'Command' = 'Clear-IcingaForWindowsManagementConsolePaginationCache';
                }
            }
        ) `
        -DefaultIndex 0 `
        -Hidden;
}

Set-Alias -Name 'IfW-FinishInstaller' -Value 'Show-IcingaForWindowsInstallerMenuFinishInstaller';
