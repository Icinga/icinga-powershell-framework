function Show-IcingaForWindowsInstallerMenuBlockClearHost()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = '0',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Clear the console output before running the installation' `
        -Entries @(
            @{
                'Caption' = 'Clear console';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'This will clear the current text of the console for a clean installation view and clear it afterwards as well';
            },
            @{
                'Caption' = 'Do not clear console';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'This will leave the console output on the console between installation steps and afterwards to possible debug purpose';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -JumpToSummary:$FALSE `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-BlockClearHost' -Value 'Show-IcingaForWindowsInstallerMenuBlockClearHost';
