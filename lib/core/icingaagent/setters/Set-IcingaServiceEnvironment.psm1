function Set-IcingaServiceEnvironment()
{
    param (
        [switch]$Force = $FALSE
    );

    if ($null -ne $Global:Icinga.Protected.Environment.'Icinga Service' -And $null -ne $Global:Icinga.Protected.Environment.'PowerShell Service' -And $Force -eq $FALSE) {
        return;
    }

    # Use scheduled tasks to fetch our current service configuration for faster load times afterwards
    $IcingaService     = Invoke-IcingaWindowsScheduledTask -JobType GetWindowsService -ObjectName 'icinga2';
    $PowerShellService = Invoke-IcingaWindowsScheduledTask -JobType GetWindowsService -ObjectName 'icingapowershell';

    # Ensure we build our internal environment variables based on each version
    # This is just required to prevent possible issues during upgrades from one version to another
    if ($Global:Icinga.Protected.ContainsKey('Environment') -eq $FALSE) {
        $Global:Icinga.Protected.Add(
            'Environment',
            @{ }
        );
    }

    if ($Global:Icinga.Protected.Environment.ContainsKey('Icinga Service') -eq $FALSE) {
        $Global:Icinga.Protected.Environment.Add(
            'Icinga Service',
            $null
        );
    }

    if ($Global:Icinga.Protected.Environment.ContainsKey('PowerShell Service') -eq $FALSE) {
        $Global:Icinga.Protected.Environment.Add(
            'PowerShell Service',
            $null
        );
    }

    $Global:Icinga.Protected.Environment.'Icinga Service'     = $IcingaService.Service;
    $Global:Icinga.Protected.Environment.'PowerShell Service' = $PowerShellService.Service;

    # In case the services are not present, ensure defaults are always set
    if ($Global:Icinga.Protected.Environment.'Icinga Service'.User -eq 'Unknown') {
        $Global:Icinga.Protected.Environment.'Icinga Service'.User = 'NT Authority\NetworkService';
    }
    if ($Global:Icinga.Protected.Environment.'PowerShell Service'.User -eq 'Unknown') {
        $Global:Icinga.Protected.Environment.'PowerShell Service'.User = 'NT Authority\NetworkService';
    }
}
