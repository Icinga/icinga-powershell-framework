function Show-IcingaForWindowsInstallationMenuEnterCustomGlobalZones()
{
    param (
        [array]$Value          = @( '' ),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please add all your global zones you want to add:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'If you have configured custom global zones you require on this Windows host, please add all of them in this list. Default zones like "director-global" and "global-templates" should not be configured here';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -AddConfig `
        -DefaultValues @( $Value ) `
        -JumpToSummary:$JumpToSummary `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-CustomZones' -Value 'Show-IcingaForWindowsInstallationMenuEnterCustomGlobalZones';
