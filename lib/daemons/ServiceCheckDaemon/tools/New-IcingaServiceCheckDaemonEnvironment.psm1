function New-IcingaServiceCheckDaemonEnvironment()
{
    param (
        $CheckCommand,
        $Arguments,
        $TimeIndexes
    );

    if ($Global:Icinga.Public.Daemons.ServiceCheck.PerformanceDataCache.ContainsKey($CheckCommand) -eq $FALSE) {
        $Global:Icinga.Public.Daemons.ServiceCheck.PerformanceDataCache.Add(
            $CheckCommand, ''
        );
    }

    $Global:Icinga.Private.Daemons.Add(
        'ServiceCheck',
        @{
            'PassedTime'         = 0;
            'SortedResult'       = $null;
            'PerformanceCache'   = @{ };
            'AverageCalculation' = @{ };
            'MaxTime'            = 0;
            'MaxTimeInSeconds'   = 0;
        }
    );

    foreach ($index in $TimeIndexes) {
        # Only allow numeric index values
        if ((Test-Numeric (ConvertTo-Seconds $index)) -eq $FALSE) {
            Write-IcingaEventMessage -EventId 1450 -Namespace 'Framework' -Objects $CheckCommand, ($Arguments | Out-String), ($TimeIndexes | Out-String), $index;
            continue;
        }
        if ($Global:Icinga.Private.Daemons.ServiceCheck.AverageCalculation.ContainsKey([string]$index) -eq $FALSE) {
            $Global:Icinga.Private.Daemons.ServiceCheck.AverageCalculation.Add(
                [string]$index,
                @{
                    'Interval'    = ([int]($index -Replace '[^0-9]', ''));
                    'RawInterval' = $index;
                    'Time'        = (ConvertTo-Seconds $index);
                    'Sum'         = 0;
                    'Count'       = 0;
                }
            );
        }
        if ($Global:Icinga.Private.Daemons.ServiceCheck.MaxTime -le (ConvertTo-Seconds $index)) {
            $Global:Icinga.Private.Daemons.ServiceCheck.MaxTime = (ConvertTo-Seconds $index);
        }
    }

    $Global:Icinga.Private.Daemons.ServiceCheck.MaxTimeInSeconds = $Global:Icinga.Private.Daemons.ServiceCheck.MaxTime;

    if ($Global:Icinga.Private.Scheduler.CheckData.ContainsKey($CheckCommand) -eq $FALSE) {
        $Global:Icinga.Private.Scheduler.CheckData.Add(
            $CheckCommand,
            @{
                'results' = @{ };
                'average' = (New-Object -TypeName PSObject);
            }
        );
    }
}
