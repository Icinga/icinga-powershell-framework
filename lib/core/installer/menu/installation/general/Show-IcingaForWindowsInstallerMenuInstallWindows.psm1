function Show-IcingaForWindowsInstallerMenuInstallWindows()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = '0',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    if ($null -eq (Get-IcingaPowerShellConfig -Path 'Framework.Config.Swap')) {
        Show-IcingaForWindowsInstallerMenuSelectConnection;
        return;
    }

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Choose the configuration type:' `
        -Entries @(
            @{
                'Caption' = 'New configuration';
                'Command' = 'Show-IcingaForWindowsInstallerMenuNewConfiguration';
                'Help'    = 'Start a new configuration and truncate all information stored on the current swap file. This will only modify your production if you hit "Start installation" at the end';
            },
            @{
                'Caption' = 'Continue configuration';
                'Command' = 'Show-IcingaForWindowsInstallerMenuContinueConfiguration';
                'Help'    = 'Continue with the previous configuration swap file.';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -Automated:$Automated `
        -Advanced:$Advanced;
}
