function Show-IcingaForWindowsInstallationMenuStableRepository()
{
    param (
        [array]$Value          = @( 'https://packages.icinga.com/IcingaForWindows/stable/ifw.repo.json' ),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please enter the path or Url for your stable Icinga repository:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'This is the stable repository from where all packages of Icinga for Windows are downloaded and installed from. Defaults to "https://packages.icinga.com/IcingaForWindows/stable/ifw.repo.json"';
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

Set-Alias -Name 'IfW-StableRepository' -Value 'Show-IcingaForWindowsInstallationMenuStableRepository';
