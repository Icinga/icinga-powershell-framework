function Show-IcingaForWindowsManagementConsoleInstallationDirectorRegisterHost()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = '0',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    $Advanced = $TRUE;

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Do you want to register the host right now inside the Icinga Director? This will show missing configurations.' `
        -Entries @(
            @{
                'Caption' = 'Do not register host inside Icinga Director';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'If you do not want to modify extended properties for this host and use default values from the Icinga Director, based on the Self-Service API configuration, use this option and complete the installation process afterwards.';
            },
            @{
                'Caption' = 'Register host inside Icinga Director';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'You can select this option to register the host within the Icinga Director right now, unlocking more advanced configurations for this host like "Parent Zone", "Parent Nodes" and "Parent Node Addresses"';
                'Action'  = @{
                    'Command'   = 'Resolve-IcingaForWindowsManagementConsoleInstallationDirectorTemplate';
                    'Arguments' = @{
                        '-Register' = $TRUE;
                    }
                }
            }
        ) `
        -DefaultIndex $DefaultInput `
        -JumpToSummary:$FALSE `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-DirectorRegisterHost' -Value 'Show-IcingaForWindowsManagementConsoleInstallationDirectorRegisterHost';
