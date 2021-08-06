function Show-IcingaForWindowsInstallerMenuSelectIcingaAgentSource()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = '0',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please select where your Icinga Agent .MSI package is downloaded from:' `
        -Entries @(
            @{
                'Caption' = 'Download from "https://packages.icinga.com"';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Download the Icinga Agent directly from "https://packages.icinga.com" for the specified version';
            },
            @{
                'Caption' = 'Use custom source';
                'Command' = 'Show-IcingaForWindowsInstallerMenuEnterIcingaAgentPackageSource';
                'Help'    = 'Specify the path on where the .MSI installer packages for the Icinga Agent can be found in your environment';
            },
            @{
                'Caption' = 'Do not install Icinga Agent';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Do not install the Icinga Agent on this system';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -JumpToSummary:$FALSE `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;

    # In case we use the default location, delete our custom location entry
    if (Get-IcingaForWindowsManagementConsoleLastInput -ne '1') {
        Remove-IcingaForWindowsInstallerConfigEntry -Menu 'Show-IcingaForWindowsInstallerMenuEnterIcingaAgentPackageSource';
    }
}

Set-Alias -Name 'IfW-AgentSource' -Value 'Show-IcingaForWindowsInstallerMenuSelectIcingaAgentSource';
