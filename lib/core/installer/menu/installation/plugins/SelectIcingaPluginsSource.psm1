function Show-IcingaForWindowsInstallerMenuSelectIcingaPluginsSource()
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
                'Caption' = 'Download latest release from GitHub';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Downloads the latest stable release directly from "https://github.com/icinga/icinga-powershell-plugins/releases"';
            },
            @{
                'Caption' = 'Download snapshot from GitHub';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Uses the master branch of the plugin repository for checkout. Not recommended in production';
            },
            @{
                'Caption' = 'Use custom source';
                'Command' = 'Show-IcingaForWindowsInstallerMenuEnterPluginsPackageSource';
                'Help'    = 'Specify a custom location from where to get your plugins from';
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

    # In case we use the default location, delete our custom location entry
    if (Get-IcingaForWindowsManagementConsoleLastInput -ne '2') {
        Remove-IcingaForWindowsInstallerConfigEntry -Menu 'Show-IcingaForWindowsInstallerMenuEnterPluginsPackageSource';
    }
}

Set-Alias -Name 'IfW-PluginSource' -Value 'Show-IcingaForWindowsInstallerMenuSelectIcingaPluginsSource';
