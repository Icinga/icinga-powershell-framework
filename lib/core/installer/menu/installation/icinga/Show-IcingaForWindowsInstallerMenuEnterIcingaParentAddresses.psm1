function Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = $null,
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    if ($Value.Count -ne 0) {

        while ($TRUE) {
            # Use the installer file/command for automation
            if ($Value[0].GetType().Name.ToLower() -eq 'pscustomobject') {

                # This is just to handle automated installation by using a file or the install command
                # We use a hashtable here as well, but reduce complexity and remove network checks

                foreach ($endpoint in  $Value[0].PSObject.Properties) {
                    Add-IcingaForWindowsInstallerConfigEntry -Selection 'c' -Values $endpoint.Value `
                        -OverwriteValues `
                        -OverwriteMenu 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses' `
                        -OverwriteParent ([string]::Format('Show-IcingaForWindowsInstallerMenuEnterIcingaParentNodes:{0}', $endpoint.Name));
                }

                return;

            } elseif ($Value[0].GetType().Name.ToLower() -eq 'hashtable') { # We will be forwarded this from Test-IcingaForWindowsInstallerParentEndpoints

                $NetworkMap        = $Value[0];
                [int]$AddressIndex = 0;

                foreach ($entry in $NetworkMap.Keys) {
                    $EndpointConfig = $NetworkMap[$entry];

                    if ($EndpointConfig.Error -eq $FALSE) {
                        $AddressIndex += 1;
                        continue;
                    }

                    $global:Icinga.InstallWizard.LastError = ([string]::Format('Failed to resolve the address for the following endpoint: {0}', $EndpointConfig.Endpoint));

                    $Address = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses' -Parent $EndpointConfig.Endpoint;

                    if ($null -eq $Address -Or $Address.Count -eq 0) {
                        $Address = @( $EndpointConfig.Address );
                    }

                    Show-IcingaForWindowsInstallerMenu `
                        -Header ([string]::Format('Please enter the connection data for endpoint: "{0}"', $EndpointConfig.Endpoint)) `
                        -Entries @(
                            @{
                                'Command' = 'break';
                                'Help'    = 'The address to communicate with your parent Icinga node. It is highly recommended to use an IP address instead of a FQDN';
                            }
                        ) `
                        -AddConfig `
                        -ConfigLimit 1 `
                        -DefaultValues $Address `
                        -MandatoryValue `
                        -ParentConfig ([string]::Format('Show-IcingaForWindowsInstallerMenuEnterIcingaParentNodes:{0}', $EndpointConfig.Endpoint)) `
                        -JumpToSummary:$JumpToSummary `
                        -ConfigElement `
                        -Automated:$Automated `
                        -Advanced:$Advanced;

                    $NewAddress = $Address;
                    $NewValue   = $Value;

                    if ((Test-IcingaForWindowsManagementConsoleContinue)) {
                        $ParentAddress = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses' -Parent $EndpointConfig.Endpoint;
                        $NetworkTest   = Convert-IcingaEndpointsToIPv4 -NetworkConfig $ParentAddress;
                        $NewAddress    = $ParentAddress;

                        if ($NetworkTest.HasErrors -eq $FALSE) {
                            Add-IcingaForWindowsInstallerConfigEntry -Selection 'c' -Values ($NetworkTest.Network[0]) -OverwriteValues -OverwriteMenu 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses';
                            $AddressIndex += 1;
                            $NewValue[0][$entry].Error = $FALSE;
                            continue;
                        }
                    }

                    Set-IcingaForWindowsManagementConsoleMenu -Menu 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses';

                    $NewValue[0][$entry].Address = $NewAddress;

                    $global:Icinga.InstallWizard.NextArguments = @{
                        'Value'         = $NewValue;
                        'DefaultInput'  = $DefaultInput;
                        'JumpToSummary' = $JumpToSummary;
                        'Automated'     = $Automated;
                        'Advanced'      = $Advanced;
                    };

                    return;
                }

                $global:Icinga.InstallWizard.NextCommand = 'Add-IcingaForWindowsInstallationAdvancedEntries';
                return;
            } elseif ($Value[0].GetType().Name.ToLower() -eq 'string') {
                $Address = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses' -Parent $Value[0];

                Show-IcingaForWindowsInstallerMenu `
                    -Header ([string]::Format('Please enter the connection data for endpoint: "{0}"', $Value[0])) `
                    -Entries @(
                        @{
                            'Command' = 'break';
                            'Help'    = 'The address to communicate with your parent Icinga node. It is highly recommended to use an IP address instead of a FQDN';
                        }
                    ) `
                    -AddConfig `
                    -ConfigLimit 1 `
                    -DefaultValues $Address `
                    -MandatoryValue `
                    -ParentConfig ([string]::Format('Show-IcingaForWindowsInstallerMenuEnterIcingaParentNodes:{0}', $Value[0])) `
                    -JumpToSummary:$JumpToSummary `
                    -ConfigElement `
                    -Automated:$Automated `
                    -Advanced:$Advanced;

                if ((Test-IcingaForWindowsManagementConsoleContinue)) {
                    $ParentAddress = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses' -Parent $Value[0];
                    $NetworkTest   = Convert-IcingaEndpointsToIPv4 -NetworkConfig $ParentAddress;

                    if ($NetworkTest.HasErrors -eq $FALSE) {
                        Add-IcingaForWindowsInstallerConfigEntry -Selection 'c' -Values ($NetworkTest.Network[0]) -OverwriteValues -OverwriteMenu 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses';
                        $global:Icinga.InstallWizard.NextCommand = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                        return;
                    }
                }
            }

            if ((Test-IcingaForWindowsManagementConsoleExit) -Or (Test-IcingaForWindowsManagementConsoleMenu) -Or (Test-IcingaForWindowsManagementConsolePrevious)) {
                return;
            }

            if ((Test-IcingaForWindowsManagementConsoleDelete)) {
                continue;
            }
        }

        # Just to ensure we never are "trapped" in a endless loop
        if ($Automated) {
            break;
        }
    }

    $global:Icinga.InstallWizard.NextCommand = 'Show-IcingaForWindowsInstallerConfigurationSummary';
}

Set-Alias -Name 'IfW-ParentAddress' -Value 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses';
