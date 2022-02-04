function Show-IcingaForWindowsInstallerMenuFinishInstaller()
{
    if ($global:Icinga.InstallWizard.DirectorSelfService -eq $TRUE -And $global:Icinga.InstallWizard.DirectorRegisteredHost -eq $FALSE) {
        $global:Icinga.InstallWizard.LastNotice = 'You are using the Icinga Director Self-Service API but have not registered the host inside the Self-Service API on the previous menu';
    }

    Show-IcingaForWindowsInstallerMenu `
        -Header 'How you do want to proceed:' `
        -Entries @(
            @{
                'Caption'        = 'Start installation';
                'Command'        = 'Start-IcingaForWindowsInstallation';
                'Help'           = 'Apply the just configured configuration and install components as selected';
                'Disabled'       = ($global:Icinga.InstallWizard.DirectorSelfService -eq $TRUE -And $global:Icinga.InstallWizard.DirectorRegisteredHost -eq $FALSE);
                'DisabledReason' = 'You are using the Icinga Director Self-Service API but have not registered the host inside the Self-Service API on the previous menu';
                'AdminMenu'      = $TRUE;
                'Action'         = @{
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
