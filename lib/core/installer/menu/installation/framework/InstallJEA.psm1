function Show-IcingaForWindowsInstallerMenuSelectInstallJEAProfile()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = '2',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    if ($PSVersionTable.PSVersion -lt '5.0.0.0') {
        return;
    }

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please select if you want to install the JEA profile for the assigned service user or to create a managed user' `
        -Entries @(
            @{
                'Caption' = 'Install JEA Profile';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Installs the Icinga for Windows JEA profile for the specified service user';
            },
            @{
                'Caption' = 'Install JEA Profile with managed user "IcingaForWindows"';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Installs the Icinga for Windows JEA profile with a newly created, managed user "IcingaForWindows". This will override your service and service password configuration';
            },
            @{
                'Caption' = 'Do not install JEA Profile';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Do not install the Icinga for Windows JEA profile';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -JumpToSummary:$FALSE `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-InstallJEAProfile' -Value 'Show-IcingaForWindowsInstallerMenuSelectInstallJEAProfile';
