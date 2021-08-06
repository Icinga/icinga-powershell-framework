function Show-IcingaForWindowsManagementConsoleEnableCodeCache()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = '0',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Do you want to enable the Icinga Framework Code Cache?' `
        -Entries @(
            @{
                'Caption' = 'Enable Icinga Framework Code Cache ';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Enables the Icinga Framework Code Cache feature during installation to decrease the loading time of the Icinga Framework. Please note that for each custom modification you do on the Icinga Framework afterwards, you will have to call "Write-IcingaFrameworkCodeCache" to rebuild the cache';
            },
            @{
                'Caption' = 'Disable Icinga Framework Code Cache';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Does not enable the Icinga Framework Code Cache and disables it during the installation process';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -JumpToSummary:$FALSE `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-CodeCache' -Value 'Show-IcingaForWindowsManagementConsoleEnableCodeCache';
