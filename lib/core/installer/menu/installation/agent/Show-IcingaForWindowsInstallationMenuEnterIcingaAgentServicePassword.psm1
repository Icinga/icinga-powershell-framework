function Show-IcingaForWindowsInstallationMenuEnterIcingaAgentServicePassword()
{
    param (
        [array]$Value          = @( ),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please enter the password for your service. Not required for system users!' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Allows you to provide a password for a service user account. This is only required for custom users, like a local or domain user. The default user does not require a password and should be left empty in this case';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -AddConfig `
        -ConfigLimit 1 `
        -PasswordInput `
        -DefaultValues @( $Value ) `
        -MandatoryValue `
        -JumpToSummary:$JumpToSummary `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-ServicePassword' -Value 'Show-IcingaForWindowsInstallationMenuEnterIcingaAgentServicePassword';
