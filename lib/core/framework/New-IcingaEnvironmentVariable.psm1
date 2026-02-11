<#
.SYNOPSIS
    Creates all environment variables for Icinga for Windows for the
    PowerShell session
.DESCRIPTION
    Creates all environment variables for Icinga for Windows for the
    PowerShell session
.EXAMPLE
    New-IcingaEnvironmentVariable;
#>

function New-IcingaEnvironmentVariable()
{
    if ($null -eq $Global:Icinga) {
        $Global:Icinga = @{ };
    }

    if ($Global:Icinga.ContainsKey('CacheBuilding') -eq $FALSE) {
        $Global:Icinga.Add('CacheBuilding', $FALSE);
    }

    # Session specific configuration for this shell
    if ($Global:Icinga.ContainsKey('Private') -eq $FALSE) {
        $Global:Icinga.Add('Private', @{ });

        $Global:Icinga.Private.Add('Daemons', @{ });
        $Global:Icinga.Private.Add('Documentation', @{ });
        $Global:Icinga.Private.Add('Timers', @{ });
        $Global:Icinga.Private.Add('ProgressStatus', @{ });
        $Global:Icinga.Private.Add(
            'RepositoryStatus',
            @{
                'FailedRepositories' = @{ };
             }
        );

        $Global:Icinga.Private.Add(
            'Scheduler',
            @{
                'CheckCommand'    = '';
                'CheckData'       = @{ };
                'ThresholdCache'  = @{ };
                'CheckResults'    = @();
                'PerformanceData' = '';
                'PluginException' = $null;
                'ExitCode'        = $null;
                'PerfDataWriter'  = @{
                    'Cache'           = @{ };
                    'Storage'         = (New-Object System.Text.StringBuilder);
                    'Daemon'          = @{ };
                    'MetricsOverTime' = '';
                }
            }
        );

        $Global:Icinga.Private.Add(
            'PerformanceCounter',
            @{
                'Cache' = @{ };
            }
        );
    }

    # Shared configuration for all threads
    if ($Global:Icinga.ContainsKey('Public') -eq $FALSE) {
        $Global:Icinga.Add('Public', [hashtable]::Synchronized(@{ }));

        $Global:Icinga.Public.Add('Daemons', @{ });
        $Global:Icinga.Public.Add('Threads', @{ });
        $Global:Icinga.Public.Add('ThreadPools', @{ });
        $Global:Icinga.Public.Add('ThreadAliveHousekeeping', @{ });
    }

    # Session specific configuration which should never be modified by users!
    if ($Global:Icinga.ContainsKey('Protected') -eq $FALSE) {
        $Global:Icinga.Add('Protected', @{ });

        $Global:Icinga.Protected.Add('DeveloperMode', $FALSE);
        $Global:Icinga.Protected.Add('DebugMode', $FALSE);
        $Global:Icinga.Protected.Add('JEAContext', $FALSE);
        $Global:Icinga.Protected.Add('RunAsDaemon', $FALSE);
        $Global:Icinga.Protected.Add('Minimal', $FALSE);
        $Global:Icinga.Protected.Add('ThreadName', '');
        $Global:Icinga.Protected.Add('GarbageCollector', @{ });
        $Global:Icinga.Protected.Add(
            'Environment', @{
                'Icinga Service'     = @{
                    'Status'      = '';
                    'Present'     = $FALSE;
                    'Name'        = 'icinga2';
                    'DisplayName' = 'icinga2';
                    'User'        = 'NT Authority\NetworkService';
                    'ServicePath' = '';
                };
                'PowerShell Service' = @{
                    'Status'      = '';
                    'Present'     = $FALSE;
                    'Name'        = 'icingapowershell';
                    'DisplayName' = 'icingapowershell';
                    'User'        = 'NT Authority\NetworkService';
                    'ServicePath' = '';
                };
                'FetchedServices'    = $FALSE;
            }
        );
        $Global:Icinga.Protected.Add('CPUSockets', ([array](Get-IcingaWindowsInformation Win32_Processor)).count);
    }
}
