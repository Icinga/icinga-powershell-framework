function Show-IcingaForWindowsManagementConsoleInstallationConfigString()
{
    [string]$ConfigurationString = [string]::Format(
        "{0}Install-Icinga -InstallCommand '{1}'{0}",
        (New-IcingaNewLine),
        (Get-IcingaForWindowsManagementConsoleConfigurationString -Compress)
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Here is your configuration command for Icinga for Windows:' `
        -Entries @(
            @{
                'Caption' = '';
                'Command' = 'Install-Icinga';
                'Help'    = 'This command provides a list of settings you entered or modified during the process. In case values are not modified, they do not show up here and are left as default. You can run this entire command on a different Windows host to apply the same configuration';
                'Action'  = @{
                    'Command' = 'Clear-IcingaForWindowsManagementConsolePaginationCache';
                }
            }
        ) `
        -AddConfig `
        -DefaultValues @( $ConfigurationString ) `
        -ConfigLimit 1 `
        -DefaultIndex 'c' `
        -ReadOnly `
        -Hidden;
}
