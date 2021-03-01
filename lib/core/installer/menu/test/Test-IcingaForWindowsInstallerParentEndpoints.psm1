function Test-IcingaForWindowsInstallerParentEndpoints()
{
    $Selection = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectConnection';

    # Agents connects, therefor validate this setting. 1 only accepts connections from parent
    if ($Selection -ne 1) {
        $Values          = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentNodes';
        $NetworkMap      = @{ };
        [bool]$HasErrors = $FALSE;

        foreach ($endpoint in $Values) {
            $Address     = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses' -Parent $endpoint;
            $TestAddress = $Address;
            if ($null -eq $Address -Or $Address.Count -eq 0) {
                $TestAddress = $endpoint;
            }

            $Resolved = Convert-IcingaEndpointsToIPv4 -NetworkConfig $TestAddress;

            if ($Resolved.HasErrors) {
                $Address   = $endpoint;
                $HasErrors = $TRUE;
            } else {
                $Address = $Resolved.Network[0];
            }

            $NetworkMap.Add(
                $endpoint,
                @{
                    'Endpoint' = $endpoint;
                    'Address'  = $Address;
                    'Error'    = $Resolved.HasErrors;
                }
            );

            Add-IcingaForWindowsInstallerConfigEntry -Selection 'c' -Values $Address -OverwriteValues `
                -OverwriteMenu 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses' `
                -OverwriteParent ([string]::Format('Show-IcingaForWindowsInstallerMenuEnterIcingaParentNodes:{0}', $endpoint));
        }

        if ($HasErrors) {
            $global:Icinga.InstallWizard.NextCommand   = 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses';
            $global:Icinga.InstallWizard.NextArguments = @{ 'Value' = $NetworkMap };
            return;
        }
    }

    $global:Icinga.InstallWizard.NextCommand   = 'Add-IcingaForWindowsInstallationAdvancedEntries';
}
