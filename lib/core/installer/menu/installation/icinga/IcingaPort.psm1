function Show-IcingaForWindowsInstallationMenuEnterIcingaPort()
{
    param (
        [array]$Value          = @( 5665 ),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please enter your parent Icinga communication port:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'This is the port Icinga will use for communicating with all parent nodes and for which the firewall must be opened, depending on your communication configuration. Defaults to 5665';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -AddConfig `
        -ConfigLimit 1 `
        -DefaultValues @( $Value ) `
        -MandatoryValue `
        -JumpToSummary:$JumpToSummary `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-Port' -Value 'Show-IcingaForWindowsInstallationMenuEnterIcingaPort';
