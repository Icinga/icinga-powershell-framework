function Show-IcingaForWindowsInstallerMenuSelectInstallIcingaForWindowsService()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = '0',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please select of you want to install the Icinga for Windows service:' `
        -Entries @(
            @{
                'Caption' = 'Install Icinga for Windows Service';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Installs the Icinga for Windows service from the provided stable repository';
            },
            @{
                'Caption' = 'Do not install Icinga for Windows service';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Select this if you do not want to install the Icinga for Windows service';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -JumpToSummary:$FALSE `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-InstallService' -Value 'Show-IcingaForWindowsInstallerMenuSelectInstallIcingaForWindowsService';
