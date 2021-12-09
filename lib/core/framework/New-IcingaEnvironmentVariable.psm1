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

    # Session specific configuration for this shell
    if ($Global:Icinga.ContainsKey('Private') -eq $FALSE) {
        $Global:Icinga.Add('Private', @{ });

        $Global:Icinga.Private.Add('Daemons', @{ });
        $Global:Icinga.Private.Add('Timers', @{ });

        $Global:Icinga.Private.Add(
            'Scheduler',
            @{
                'CheckData'       = @{ };
                'ThresholdCache'  = @{ };
                'CheckResults'    = @();
                'PerformanceData' = @();
                'PluginException' = $null;
                'ExitCode'        = $null;
            }
        );
    }

    # Shared configuration for all threads
    if ($Global:Icinga.ContainsKey('Public') -eq $FALSE) {
        $Global:Icinga.Add('Public', [hashtable]::Synchronized(@{ }));

        $Global:Icinga.Public.Add('Daemons', @{ });
        $Global:Icinga.Public.Add('Threads', @{ });
        $Global:Icinga.Public.Add('ThreadPools', @{ });
        $Global:Icinga.Public.Add(
            'PerformanceCounter',
            @{
                'Cache' = @{ };
            }
        );
    }

    # Session specific configuration which should never be modified by users!
    if ($Global:Icinga.ContainsKey('Protected') -eq $FALSE) {
        $Global:Icinga.Add('Protected', @{ });

        $Global:Icinga.Protected.Add('DebugMode', $FALSE);
        $Global:Icinga.Protected.Add('JEAContext', $FALSE);
        $Global:Icinga.Protected.Add('RunAsDaemon', $FALSE);
        $Global:Icinga.Protected.Add('Minimal', $FALSE);
    }
}
