function Show-IcingaForWindowsInstallationMenuEnterWindowsServiceDirectory()
{
    param (
        [array]$Value          = @( (Join-Path -Path $Env:ProgramFiles -ChildPath 'icinga-framework-service') ),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Enter the path where to install the Icinga for Windows service binary into:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'If you want to run a background PowerShell daemon, you will require a binary starting the shell as service. This is the permanent location for the binary, as the Icinga for Windows service is registered with this binary to run PowerShell as background daemon';
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

Set-Alias -Name 'IfW-WindowsServiceDirectory' -Value 'Show-IcingaForWindowsInstallationMenuEnterWindowsServiceDirectory';
