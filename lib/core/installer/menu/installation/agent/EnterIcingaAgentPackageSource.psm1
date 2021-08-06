function Show-IcingaForWindowsInstallerMenuEnterIcingaAgentPackageSource()
{
    param (
        [array]$Value          = @( 'https://packages.icinga.com/windows/' ),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please enter the location on where to find your Icinga Agent installation package:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'The location on where to find your Icinga Agent .MSI packages. You can specify a local path "C:\icinga\msi", a network path "\\example.com\software\icinga\" or a web path "https://example.com/icinga/windows". For the last variant it is required that the web server is printing the directory file list.';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -AddConfig `
        -ConfigLimit 1 `
        -DefaultValues $Value `
        -ContinueFirstValue `
        -MandatoryValue `
        -JumpToSummary:$JumpToSummary `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-AgentPackageSource' -Value 'Show-IcingaForWindowsInstallerMenuEnterIcingaAgentPackageSource';
