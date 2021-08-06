function Show-IcingaForWindowsInstallationMenuEnterIcingaAgentDirectory()
{
    param (
        [array]$Value          = @( (Join-Path -Path $Env:ProgramFiles -ChildPath 'ICINGA2') ),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Enter the path where to install the Icinga Agent into:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Allows you to override the location on where the Icinga Agent will be installed into';
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

Set-Alias -Name 'IfW-AgentDirectory' -Value 'Show-IcingaForWindowsInstallationMenuEnterIcingaAgentDirectory';
