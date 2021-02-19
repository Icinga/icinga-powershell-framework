function Show-IcingaForWindowsInstallerMenuEnterWindowsServicePackageSource()
{
    param (
        [array]$Value          = @( ),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please enter the full path to the Icinga PowerShell Service .zip file:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Allows you to specify a full custom path on where your Icinga service package .zip file is located at. You can specify a local path "C:\icinga\service\icinga-service.zip", a network path "\\example.com\software\icinga\service\icinga-service.zip" or a web path "https://example.com/icinga/windows/service/icinga-service.zip". Please note that only the custom release .zip packages downloaded from "https://github.com/Icinga/icinga-powershell-service/releases" will work. You can get the packages from there and place them on your custom location';
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

Set-Alias -Name 'IfW-WindowsServicePackageSource' -Value 'Show-IcingaForWindowsInstallerMenuEnterWindowsServicePackageSource';
