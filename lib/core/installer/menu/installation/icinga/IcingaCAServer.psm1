function Show-IcingaForWindowsInstallationMenuEnterIcingaCAServer()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    if ($null -eq $Value -or $Value.Count -eq 0) {
        $IcingaEndpoints = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentNodes';

        foreach ($endpoint in $IcingaEndpoints) {
            $EndpointAddress = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses' -Parent $endpoint;

            if ($null -ne $EndpointAddress -And [string]::IsNullOrEmpty($EndpointAddress) -eq $FALSE) {
                $Value += $EndpointAddress;
                break;
            }
        }
    }

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please enter your Icinga CA server:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'This is the Icinga endpoint to connect to for signing your certificates. This can be a satellite, as requests will be forwarded to your CA server.';
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

Set-Alias -Name 'IfW-CAServer' -Value 'Show-IcingaForWindowsInstallationMenuEnterIcingaCAServer';
