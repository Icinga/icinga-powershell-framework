function Set-IcingaServiceEnvironment()
{
    param (
        [switch]$Force = $FALSE
    );

    # Don't do anything if we are not inside an administrative shell
    if ((Test-AdministrativeShell) -eq $FALSE) {
        return;
    }

    # Ensure we build our internal environment variables based on each version
    # This is just required to prevent possible issues during upgrades from one version to another
    if ($Global:Icinga.Protected.ContainsKey('Environment') -eq $FALSE) {
        $Global:Icinga.Protected.Add(
            'Environment',
            @{ }
        );
    }

    if ($Global:Icinga.Protected.ContainsKey('Environment') -eq $FALSE) {
        $Global:Icinga.Protected.Add(
            'Environment',
            @{ }
        );
    }

    if ($Global:Icinga.Protected.Environment.ContainsKey('FetchedServices') -eq $FALSE) {
        $Global:Icinga.Protected.Environment.Add(
            'FetchedServices', $FALSE
        );
    }

    if ($Global:Icinga.Protected.Environment.ContainsKey('Icinga Service') -eq $FALSE) {
        $Global:Icinga.Protected.Environment.Add(
            'Icinga Service',
            @{
                'Status'      = '';
                'Present'     = $FALSE;
                'Name'        = 'icinga2';
                'DisplayName' = 'icinga2';
                'User'        = 'NT Authority\NetworkService';
                'ServicePath' = '';
            }
        );
    }

    if ($Global:Icinga.Protected.Environment.ContainsKey('PowerShell Service') -eq $FALSE) {
        $Global:Icinga.Protected.Environment.Add(
            'PowerShell Service',
            @{
                'Status'      = '';
                'Present'     = $FALSE;
                'Name'        = 'icingapowershell';
                'DisplayName' = 'icingapowershell';
                'User'        = 'NT Authority\NetworkService';
                'ServicePath' = '';
            }
        );
    }

    if ($Global:Icinga.Protected.Environment.FetchedServices) {
        return;
    }

    # Use scheduled tasks to fetch our current service configuration for faster load times afterwards
    $IcingaService     = Invoke-IcingaWindowsScheduledTask -JobType GetWindowsService -ObjectName 'icinga2';
    $PowerShellService = Invoke-IcingaWindowsScheduledTask -JobType GetWindowsService -ObjectName 'icingapowershell';

    if ($null -ne $IcingaService -And $null -ne $IcingaService.Service) {
        $Global:Icinga.Protected.Environment.'Icinga Service'     = $IcingaService.Service;
    }

    if ($null -ne $PowerShellService -And $null -ne $PowerShellService.Service) {
        $Global:Icinga.Protected.Environment.'PowerShell Service' = $PowerShellService.Service;
    }

    # In case the services are not present, ensure defaults are always set
    if ($Global:Icinga.Protected.Environment.'Icinga Service'.User -eq 'Unknown') {
        $Global:Icinga.Protected.Environment.'Icinga Service'.User = 'NT Authority\NetworkService';
    }
    if ($Global:Icinga.Protected.Environment.'PowerShell Service'.User -eq 'Unknown') {
        $Global:Icinga.Protected.Environment.'PowerShell Service'.User = 'NT Authority\NetworkService';
    }

    $Global:Icinga.Protected.Environment.FetchedServices = $TRUE;
}
