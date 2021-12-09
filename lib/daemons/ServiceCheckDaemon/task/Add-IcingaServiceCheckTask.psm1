function Add-IcingaServiceCheckTask()
{
    param (
        $CheckCommand,
        $Arguments,
        $Interval,
        $TimeIndexes,
        $CheckId
    );

    # $Global:Icinga.Private.Daemons.ServiceCheck
    New-IcingaServiceCheckDaemonEnvironment `
        -CheckCommand $CheckCommand `
        -Arguments $Arguments `
        -TimeIndexes $TimeIndexes;

    # Read our check result store data from disk for this service check
    Read-IcingaCheckResultStore -CheckCommand $CheckCommand;

    while ($TRUE) {
        if ($Global:Icinga.Private.Daemons.ServiceCheck.PassedTime -lt $Interval) {
            $Global:Icinga.Private.Daemons.ServiceCheck.PassedTime += 1;
            Start-Sleep -Seconds 1;

            continue;
        }

        $Global:Icinga.Private.Daemons.ServiceCheck.PassedTime = 0;

        # Execute our check with possible arguments
        try {
            & $CheckCommand @Arguments | Out-Null;
        } catch {
            Write-IcingaEventMessage -EventId 1451 -Namespace 'Framework' -ExceptionObject $_ -Objects $CheckCommand, ($Arguments | Out-String), (Get-IcingaInternalPluginOutput);

            Clear-IcingaCheckSchedulerEnvironment;

            # Force Icinga for Windows Garbage Collection
            Optimize-IcingaForWindowsMemory -ClearErrorStack;

            continue;
        }

        $UnixTime = Get-IcingaUnixTime;

        try {
            foreach ($result in $global:Icinga.Private.Scheduler.CheckData[$CheckCommand]['results'].Keys) {
                [string]$HashIndex                                       = $result;
                $Global:Icinga.Private.Daemons.ServiceCheck.SortedResult = $global:Icinga.Private.Scheduler.CheckData[$CheckCommand]['results'][$HashIndex].GetEnumerator() | Sort-Object name -Descending;

                Add-IcingaHashtableItem `
                    -Hashtable $Global:Icinga.Private.Daemons.ServiceCheck.PerformanceCache `
                    -Key $HashIndex `
                    -Value @{ } | Out-Null;

                foreach ($timeEntry in $Global:Icinga.Private.Daemons.ServiceCheck.SortedResult) {

                    if ((Test-Numeric $timeEntry.Value) -eq $FALSE) {
                        continue;
                    }

                    foreach ($calc in $Global:Icinga.Private.Daemons.ServiceCheck.AverageCalculation.Keys) {
                        if (($UnixTime - $Global:Icinga.Private.Daemons.ServiceCheck.AverageCalculation[$calc].Time) -le [int]$timeEntry.Key) {
                            $Global:Icinga.Private.Daemons.ServiceCheck.AverageCalculation[$calc].Sum   += $timeEntry.Value;
                            $Global:Icinga.Private.Daemons.ServiceCheck.AverageCalculation[$calc].Count += 1;
                        }
                    }
                    if (($UnixTime - $Global:Icinga.Private.Daemons.ServiceCheck.MaxTimeInSeconds) -le [int]$timeEntry.Key) {
                        Add-IcingaHashtableItem `
                            -Hashtable $Global:Icinga.Private.Daemons.ServiceCheck.PerformanceCache[$HashIndex] `
                            -Key ([string]$timeEntry.Key) `
                            -Value ([string]$timeEntry.Value) | Out-Null;
                    }
                }

                foreach ($calc in $Global:Icinga.Private.Daemons.ServiceCheck.AverageCalculation.Keys) {
                    if ($Global:Icinga.Private.Daemons.ServiceCheck.AverageCalculation[$calc].Count -ne 0) {
                        $AverageValue         = ($Global:Icinga.Private.Daemons.ServiceCheck.AverageCalculation[$calc].Sum / $Global:Icinga.Private.Daemons.ServiceCheck.AverageCalculation[$calc].Count);
                        [string]$MetricName   = Format-IcingaPerfDataLabel (
                            [string]::Format('{0}_{1}', $HashIndex, $Global:Icinga.Private.Daemons.ServiceCheck.AverageCalculation[$calc].Interval)
                        );

                        $Global:Icinga.Private.Scheduler.CheckData[$CheckCommand]['average'] | Add-Member -MemberType NoteProperty -Name $MetricName -Value $AverageValue -Force;
                    }

                    $Global:Icinga.Private.Daemons.ServiceCheck.AverageCalculation[$calc].Sum   = 0;
                    $Global:Icinga.Private.Daemons.ServiceCheck.AverageCalculation[$calc].Count = 0;
                }
            }

            Write-IcingaDebugMessage `
                -Message 'Object dump of service check daemon' `
                -Objects @(
                    $CheckCommand,
                    'Average Calc',
                    ($Global:Icinga.Private.Daemons.ServiceCheck.AverageCalculation | Out-String),
                    'PerformanceCache',
                    $Global:Icinga.Private.Daemons.ServiceCheck.PerformanceCache,
                    'Max Time in Seconds',
                    $Global:Icinga.Private.Daemons.ServiceCheck.MaxTimeInSeconds,
                    'Unix Time',
                    $UnixTime
                );

            # Flush data we no longer require in our cache to free memory
            [array]$CheckStores = $Global:Icinga.Private.Scheduler.CheckData[$CheckCommand]['results'].Keys;

            foreach ($CheckStore in $CheckStores) {
                [string]$CheckKey       = $CheckStore;
                [array]$CheckTimeStamps = $global:Icinga.Private.Scheduler.CheckData[$CheckCommand]['results'][$CheckKey].Keys;

                foreach ($TimeSample in $CheckTimeStamps) {
                    if (($UnixTime - $Global:Icinga.Private.Daemons.ServiceCheck.MaxTimeInSeconds) -gt [int]$TimeSample) {
                        Remove-IcingaHashtableItem -Hashtable $global:Icinga.Private.Scheduler.CheckData[$CheckCommand]['results'][$CheckKey] -Key ([string]$TimeSample);
                    }
                }
            }

            Set-IcingaCacheData -Space 'sc_daemon' -CacheStore 'checkresult' -KeyName $CheckCommand -Value $global:Icinga.Private.Scheduler.CheckData[$CheckCommand]['average'];

            # Make the performance data available for all threads
            $Global:Icinga.Public.Daemons.ServiceCheck.PerformanceDataCache[$CheckCommand] = $global:Icinga.Private.Scheduler.CheckData[$CheckCommand]['average'];
            # Write collected metrics to disk in case we reload the daemon. We will load them back into the module after reload then
            Set-IcingaCacheData -Space 'sc_daemon' -CacheStore 'checkresult_store' -KeyName $CheckCommand -Value $Global:Icinga.Private.Daemons.ServiceCheck.PerformanceCache;

        } catch {
            Write-IcingaEventMessage -EventId 1452 -Namespace 'Framework' -ExceptionObject $_ -Objects $CheckCommand, ($Arguments | Out-String), (Get-IcingaInternalPluginOutput);
        }

        # Always ensure our check data is cleared regardless of possible
        # exceptions which might occur
        Clear-IcingaCheckSchedulerEnvironment;
        # Reset certain values from the scheduler environment
        Clear-IcingaServiceCheckDaemonEnvironment;
        # Force Icinga for Windows Garbage Collection
        Optimize-IcingaForWindowsMemory -ClearErrorStack;
    }
}
