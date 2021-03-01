function Show-IcingaForWindowsInstallerMenuEnterIcingaParentNodes()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    $Endpoints = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentNodes';

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please enter your parent Icinga node name(s):' `
        -Entries @(
            @{
                'Command' = 'Test-IcingaForWindowsInstallerParentEndpoints';
                'Help'    = 'These are the object names for your parent Icinga endpoints as defined within the zones.conf. If you are running multiple Icinga instances within the same zone, you require to add both of them';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -AddConfig `
        -ConfigLimit 2 `
        -DefaultValues $Value `
        -ContinueFirstValue `
        -MandatoryValue `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;

    # In case we delete our parent config, ensure we also delete our endpoint addresses
    if (Test-IcingaForWindowsManagementConsoleDelete) {
        foreach ($endpoint in $Endpoints) {
            Remove-IcingaForWindowsInstallerConfigEntry -Menu 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses' -Parent $endpoint;
        }
    }
}

Set-Alias -Name 'IfW-ParentNodes' -Value 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentNodes';
