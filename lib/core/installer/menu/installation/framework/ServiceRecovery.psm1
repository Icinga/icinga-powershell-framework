function Show-IcingaForWindowsInstallerMenuSelectServiceRecovery()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = '1',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please select if you want to enable or disable automatic service recovery' `
        -Entries @(
            @{
                'Caption' = 'Disable automatic service recovery';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Enables automatic service recovery for the Icinga Agent and Icinga for Windows service, in case the server terminates itself because of errors';
            },
            @{
                'Caption' = 'Enable automatic service recovery';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Disables automatic service recovery for the Icinga Agent and Icinga for Windows service, in case the server terminates itself because of errors';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -JumpToSummary:$FALSE `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-ServiceRecovery' -Value 'Show-IcingaForWindowsInstallerMenuSelectServiceRecovery';
