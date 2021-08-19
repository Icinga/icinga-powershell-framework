function Show-IcingaForWindowsManagementConsoleInstallationEnterDirectorUrl()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    $Global:Icinga.InstallWizard.DirectorSelfService = $TRUE;

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please enter the URL pointing to your Icinga Director module:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsManagementConsoleInstallationEnterDirectorSelfServiceKey';
                'Help'    = 'The Icinga Web 2 url pointing directly to the root of the Icinga Director module. Example: "https://example.com/icingaweb2/director" or "https://icinga.example.com/director"';
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

Set-Alias -Name 'IfW-DirectorUrl' -Value 'Show-IcingaForWindowsManagementConsoleInstallationEnterDirectorUrl';
