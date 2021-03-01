function Show-IcingaForWindowsInstallerMenuSelectOpenWindowsFirewall()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = '1',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please select if your Windows Firewall should be opened for the Icinga port:' `
        -Entries @(
            @{
                'Caption' = 'Open Windows Firewall for incoming Icinga connections';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'This will open the Windows Firewall for the configured Icinga Port, to allow incoming communication from Icinga parent node(s)';
            },
            @{
                'Caption' = 'Do not open Windows Firewall for incoming Icinga connections';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Do not open the Windows firewall for any incoming Icinga connections. Please note that in case your Icinga Agent is configured for "Connecting from parent system" you will not be able to establish a communication unless the connection type is changed or the port is opened';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -JumpToSummary:$FALSE `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-WindowsFirewall' -Value 'Show-IcingaForWindowsInstallerMenuSelectOpenWindowsFirewall';
