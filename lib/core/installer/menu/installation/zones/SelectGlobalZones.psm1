function Show-IcingaForWindowsInstallerMenuSelectGlobalZones()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = '0',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Which default Icinga global zones do you want to add?' `
        -Entries @(
            @{
                'Caption' = 'Add "director-global" and "global-templates" zones';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Adds both global zones, "director-global" and "global-templates" as the default installer would. Depending on your environment these might be mandatory.';
            },
            @{
                'Caption' = 'Add "director-global" zone';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Only add the global zone "director-global" to your configuration which might be required if you are using the Icinga Director, depending on your configuration.';
            },
            @{
                'Caption' = 'Add "global-templates" zone';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Only add the global zone "global-templates" to your configuration';
            },
            @{
                'Caption' = 'Add no default global zone';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Do not add any default global zones to your configuration';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -JumpToSummary:$JumpToSummary `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-GlobalZones' -Value 'Show-IcingaForWindowsInstallerMenuSelectGlobalZones';
