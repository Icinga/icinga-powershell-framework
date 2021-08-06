function Add-IcingaServiceCheckTask()
{
    param (
        $IcingaDaemonData,
        $CheckCommand,
        $Arguments,
        $Interval,
        $TimeIndexes,
        $CheckId
    );

    Use-Icinga -LibOnly -Daemon;

    $PassedTime   = 0;
    $SortedResult = $null;
    $PerfCache    = @{ };
    $AverageCalc  = @{ };
    [int]$MaxTime = 0;

    # Initialise some global variables we use to actually store check result data from
    # plugins properly. This is doable from each thread instance as this part isn't
    # shared between daemons
    New-IcingaCheckSchedulerEnvironment;

    foreach ($index in $TimeIndexes) {
        # Only allow numeric index values
        if ((Test-Numeric $index) -eq $FALSE) {
            continue;
        }
        if ($AverageCalc.ContainsKey([string]$index) -eq $FALSE) {
            $AverageCalc.Add(
                [string]$index,
                @{
                    'Interval' = ([int]$index);
                    'Time'     = ([int]$index * 60);
                    'Sum'      = 0;
                    'Count'    = 0;
                }
            );
        }
        if ($MaxTime -le [int]$index) {
            $MaxTime = [int]$index;
        }
    }

    [int]$MaxTimeInSeconds = $MaxTime * 60;

    if (-Not ($global:Icinga.CheckData.ContainsKey($CheckCommand))) {
        $global:Icinga.CheckData.Add($CheckCommand, @{ });
        $global:Icinga.CheckData[$CheckCommand].Add('results', @{ });
        $global:Icinga.CheckData[$CheckCommand].Add('average', @{ });
    }

    $LoadedCacheData = Get-IcingaCacheData -Space 'sc_daemon' -CacheStore 'checkresult_store' -KeyName $CheckCommand;

    if ($null -ne $LoadedCacheData) {
        foreach ($entry in $LoadedCacheData.PSObject.Properties) {
            $global:Icinga.CheckData[$CheckCommand]['results'].Add(
                $entry.name,
                @{ }
            );
            foreach ($item in $entry.Value.PSObject.Properties) {
                $global:Icinga.CheckData[$CheckCommand]['results'][$entry.name].Add(
                    $item.Name,
                    $item.Value
                );
            }
        }
    }

    while ($TRUE) {
        if ($PassedTime -ge $Interval) {
            try {
                & $CheckCommand @Arguments | Out-Null;
            } catch {
                # Just for debugging. Not required in production or usable at all
                $ErrMsg = $_.Exception.Message;
                Write-IcingaConsoleError $ErrMsg;
            }

            try {
                $UnixTime = Get-IcingaUnixTime;

                foreach ($result in $global:Icinga.CheckData[$CheckCommand]['results'].Keys) {
                    [string]$HashIndex = $result;
                    $SortedResult = $global:Icinga.CheckData[$CheckCommand]['results'][$HashIndex].GetEnumerator() | Sort-Object name -Descending;
                    Add-IcingaHashtableItem -Hashtable $PerfCache -Key $HashIndex -Value @{ } | Out-Null;

                    foreach ($timeEntry in $SortedResult) {

                        if ((Test-Numeric $timeEntry.Value) -eq $FALSE) {
                            continue;
                        }

                        foreach ($calc in $AverageCalc.Keys) {
                            if (($UnixTime - $AverageCalc[$calc].Time) -le [int]$timeEntry.Key) {
                                $AverageCalc[$calc].Sum   += $timeEntry.Value;
                                $AverageCalc[$calc].Count += 1;
                            }
                        }
                        if (($UnixTime - $MaxTimeInSeconds) -le [int]$timeEntry.Key) {
                            Add-IcingaHashtableItem -Hashtable $PerfCache[$HashIndex] -Key ([string]$timeEntry.Key) -Value ([string]$timeEntry.Value) | Out-Null;
                        }
                    }

                    foreach ($calc in $AverageCalc.Keys) {
                        if ($AverageCalc[$calc].Count -ne 0) {
                            $AverageValue         = ($AverageCalc[$calc].Sum / $AverageCalc[$calc].Count);
                            [string]$MetricName   = Format-IcingaPerfDataLabel (
                                [string]::Format('{0}_{1}', $HashIndex, $AverageCalc[$calc].Interval)
                            );

                            Add-IcingaHashtableItem `
                                -Hashtable $global:Icinga.CheckData[$CheckCommand]['average'] `
                                -Key $MetricName -Value $AverageValue -Override | Out-Null;
                        }

                        $AverageCalc[$calc].Sum   = 0;
                        $AverageCalc[$calc].Count = 0;
                    }
                }

                # Flush data we no longer require in our cache to free memory
                [array]$CheckStores = $global:Icinga.CheckData[$CheckCommand]['results'].Keys;

                foreach ($CheckStore in $CheckStores) {
                    [string]$CheckKey       = $CheckStore;
                    [array]$CheckTimeStamps = $global:Icinga.CheckData[$CheckCommand]['results'][$CheckKey].Keys;

                    foreach ($TimeSample in $CheckTimeStamps) {
                        if (($UnixTime - $MaxTimeInSeconds) -gt [int]$TimeSample) {
                            Remove-IcingaHashtableItem -Hashtable $global:Icinga.CheckData[$CheckCommand]['results'][$CheckKey] -Key ([string]$TimeSample);
                        }
                    }
                }

                Set-IcingaCacheData -Space 'sc_daemon' -CacheStore 'checkresult' -KeyName $CheckCommand -Value $global:Icinga.CheckData[$CheckCommand]['average'];
                # Write collected metrics to disk in case we reload the daemon. We will load them back into the module after reload then
                Set-IcingaCacheData -Space 'sc_daemon' -CacheStore 'checkresult_store' -KeyName $CheckCommand -Value $PerfCache;
            } catch {
                # Just for debugging. Not required in production or usable at all
                $ErrMsg = $_.Exception.Message;
                Write-IcingaConsoleError 'Failed to handle check result processing: {0}' -Objects $ErrMsg;
            }

            # Cleanup the error stack and remove not required data
            $Error.Clear();

            # Always ensure our check data is cleared regardless of possible
            # exceptions which might occur
            Get-IcingaCheckSchedulerPerfData | Out-Null;
            Get-IcingaCheckSchedulerPluginOutput | Out-Null;

            $PassedTime   = 0;
            $SortedResult.Clear();
            $PerfCache.Clear();
        }

        $PassedTime += 1;
        Start-Sleep -Seconds 1;
        # Force PowerShell to call the garbage collector to free memory
        [System.GC]::Collect();
    }
}
