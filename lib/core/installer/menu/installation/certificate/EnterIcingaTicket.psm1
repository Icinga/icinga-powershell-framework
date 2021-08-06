function Show-IcingaForWindowsInstallerMenuEnterIcingaTicket()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    $Advanced = $TRUE;

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please enter your ticket for signing the Icinga certificate:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'The ticket required for signing your local Icinga certificate. You can get the ticket from the Icinga Director for this host or from your Icinga CA master by running "icinga2 pki ticket --cn <hostname as selected before>"';
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

Set-Alias -Name 'IfW-Ticket' -Value 'Show-IcingaForWindowsInstallerMenuEnterIcingaTicket';
