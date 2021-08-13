function Show-IcingaForWindowsInstallerMenuSelectInstallIcingaAgent()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = '0',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please select if the Icinga Agent should be installed' `
        -Entries @(
            @{
                'Caption' = 'Install Icinga Agent';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Downloads the Icinga Agent from the specified stable repository and installs it';
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
}

Set-Alias -Name 'IfW-InstallAgent' -Value 'Show-IcingaForWindowsInstallerMenuSelectInstallIcingaAgent';
