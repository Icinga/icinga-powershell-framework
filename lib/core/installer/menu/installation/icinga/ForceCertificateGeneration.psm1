function Show-IcingaForWindowsInstallerMenuSelectForceCertificateGeneration()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = '0',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Do you want to force the creation of possible existing Icinga Agent certificates?' `
        -Entries @(
            @{
                'Caption' = 'Do not enforce certificate creation';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'In case certificates for the Icinga Agent for the matching hostname do already exist, they will not be re-created.'
            },
            @{
                'Caption' = 'Enforce certificate creation';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'This will always create the Icinga Agent certificates and create a new certificate request, even when certificates do already exist.';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -JumpToSummary:$JumpToSummary `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-ForceCertificateCreation' -Value 'Show-IcingaForWindowsInstallerMenuSelectForceCertificateGeneration';
