function Show-IcingaForWindowsInstallerMenuSelectInstallIcingaPlugins()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = '0',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please select where your Icinga plugins are downloaded from:' `
        -Entries @(
            @{
                'Caption' = 'Install plugins';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Installs the Icinga Plugins from the defined stable repository';
            },
            @{
                'Caption' = 'Do not install plugins';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Select this if you do not want to install the plugins for the moment';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -JumpToSummary:$FALSE `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-InstallPlugins' -Value 'Show-IcingaForWindowsInstallerMenuSelectInstallIcingaPlugins';
