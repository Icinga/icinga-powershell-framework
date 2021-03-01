function Show-IcingaForWindowsInstallerMenuEnterIcingaParentZone()
{
    param (
        [array]$Value          = @( 'master' ),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please enter your parent Icinga zone:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentNodes';
                'Help'    = 'The object name of the zone of the parent Icinga node(s) you want to communicate with, as defined within the zones.conf';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -AddConfig `
        -ConfigLimit 1 `
        -DefaultValues $Value `
        -MandatoryValue `
        -JumpToSummary:$JumpToSummary `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-ParentZone' -Value 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentZone';
