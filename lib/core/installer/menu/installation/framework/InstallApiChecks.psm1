function Show-IcingaForWindowsInstallerMenuSelectInstallApiChecks()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = '1',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please select if you want to enable the Api-Checks feature' `
        -Entries @(
            @{
                'Caption' = 'Do not install Api-Checks feature';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Does neither register the REST-Api background daemon nor enables the Api-Check feature';
            },
            @{
                'Caption' = 'Install Api-Checks feature';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Enables the Icinga for Windows REST-Api background daemon and enables the Api-Check feature, which results in every check executed by "Exit-IcingaExecutePlugin" to be forwarded to the internal API. This will provide a huge performance boost for plugin execution. Also enables all checks for the namespace "Invoke-IcingaCheck*" to be executed over the Api. The REST-Api is only configured to run on localhost. Requires the Icinga for Windows service to be installed.';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -JumpToSummary:$FALSE `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-InstallApiChecks' -Value 'Show-IcingaForWindowsInstallerMenuSelectInstallApiChecks';
