function Show-IcingaForWindowsInstallerMenuEnterPluginsPackageSource()
{
    param (
        [array]$Value          = @( ),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please enter the full path to the Icinga PowerShell Plugins .zip file:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Allows you to specify a full custom path on where your Icinga plugins .zip file is located at. You can specify a local path "C:\icinga\plugins\icinga-powershell-plugins.zip", a network path "\\example.com\software\icinga\plugins\icinga-powershell-plugins.zip" or a web path "https://example.com/icinga/windows/plugins/icinga-powershell-plugins.zip". Please note that only .zip packages downloaded from "https://github.com/icinga/icinga-powershell-plugins/releases" will work. You can get the packages from there and place them on your custom location';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -AddConfig `
        -ConfigLimit 1 `
        -DefaultValues $Value `
        -ContinueFirstValue `
        -MandatoryValue `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-PluginPackageSource' -Value 'Show-IcingaForWindowsInstallerMenuEnterPluginsPackageSource';
