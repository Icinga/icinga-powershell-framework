function Show-IcingaForWindowsInstallerMenuSelectWindowsServiceSource()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = '0',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please select where the Icinga for Windows service binary is downloaded from:' `
        -Entries @(
            @{
                'Caption' = 'Download latest release from GitHub';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Download the latest stable release of the service binary directly from "https://github.com/Icinga/icinga-powershell-service/releases"';
            },
            @{
                'Caption' = 'Use custom source';
                'Command' = 'Show-IcingaForWindowsInstallerMenuEnterWindowsServicePackageSource';
                'Help'    = 'Specify a custom location from where to get the Icinga for Windows service package';
            },
            @{
                'Caption' = 'Do not install service';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Select this if you do not want to install the Icinga for Windows service';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -JumpToSummary:$FALSE `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;

    # In case we use the default location, delete our custom location entry
    if (Get-IcingaForWindowsManagementConsoleLastInput -ne '1') {
        Remove-IcingaForWindowsInstallerConfigEntry -Menu 'Show-IcingaForWindowsInstallerMenuEnterWindowsServicePackageSource';
    }
}

Set-Alias -Name 'IfW-WindowsServiceSource' -Value 'Show-IcingaForWindowsInstallerMenuSelectWindowsServiceSource';
