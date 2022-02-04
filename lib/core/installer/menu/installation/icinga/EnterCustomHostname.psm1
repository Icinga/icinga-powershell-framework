function Show-IcingaForWindowsInstallationMenuEnterCustomHostname()
{
    param (
        [array]$Value          = @( (Get-IcingaHostname -AutoUseHostname 1 -LowerCase 1) ),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please enter your hostname:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentZone';
                'Help'    = 'A custom hostname being used for generating certificates and for usage within Icinga';
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

Set-Alias -Name 'IfW-CustomHostname' -Value 'Show-IcingaForWindowsInstallationMenuEnterCustomHostname';
