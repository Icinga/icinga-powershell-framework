function Show-IcingaForWindowsInstallationMenuEnterIcingaAgentVersion()
{
    param (
        [array]$Value          = @( 'release' ),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please specify the version of the Icinga Agent you want to install:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Allows you to define which Icinga Agent version is installed on this system. The installer will search for the .MSI package for the specified version on the source location. You can either use "release" to install the highest version found, use "snapshot" to install snapshot packages or specify a direct version like "2.12.3"';
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

Set-Alias -Name 'IfW-AgentVersion' -Value 'Show-IcingaForWindowsInstallationMenuEnterIcingaAgentVersion';
