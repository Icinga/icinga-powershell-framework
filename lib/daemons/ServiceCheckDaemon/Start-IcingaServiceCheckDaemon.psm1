function Start-IcingaServiceCheckDaemon()
{
    $ScriptBlock = {
        param($IcingaDaemonData);

        Use-Icinga -LibOnly -Daemon;

        $IcingaDaemonData.BackgroundDaemon.Add('ServiceCheckScheduler', [hashtable]::Synchronized(@{}));
        $IcingaDaemonData.IcingaThreadPool.Add('ServiceCheckPool', (New-IcingaThreadPool -MaxInstances (Get-IcingaConfigTreeCount -Path 'BackgroundDaemon.RegisteredServices')));

        while ($TRUE) {

            $RegisteredServices = Get-IcingaRegisteredServiceChecks;

            foreach ($service in $RegisteredServices.Keys) {
                [string]$ThreadName = [string]::Format('Icinga_Background_Service_Check_{0}', $service);
                if ((Test-IcingaThread $ThreadName)) {
                    continue;
                }

                Start-IcingaServiceCheckTask -CheckId $service -CheckCommand $RegisteredServices[$service].CheckCommand -Arguments $RegisteredServices[$service].Arguments -Interval $RegisteredServices[$service].Interval -TimeIndexes $RegisteredServices[$service].TimeIndexes;
            }
            Start-Sleep -Seconds 1;
        }
    };

    New-IcingaThreadInstance -Name "Icinga_PowerShell_ServiceCheck_Scheduler" -ThreadPool $IcingaDaemonData.IcingaThreadPool.BackgroundPool -ScriptBlock $ScriptBlock -Arguments @( $global:IcingaDaemonData ) -Start;
}

function Start-IcingaServiceCheckTask()
{
    param(
        $CheckId,
        $CheckCommand,
        $Arguments,
        $Interval,
        $TimeIndexes
    );

    [string]$ThreadName = [string]::Format('Icinga_Background_Service_Check_{0}', $CheckId);

    $ScriptBlock = {
        param($IcingaDaemonData, $CheckCommand, $Arguments, $Interval, $TimeIndexes, $CheckId);

        Use-Icinga -LibOnly -Daemon;
        $PassedTime   = 0;
        $SortedResult = $null;
        $OldData      = @{};
        $PerfCache    = @{};
        $AverageCalc  = @{};
        [int]$MaxTime = 0;

        foreach ($index in $TimeIndexes) {
            # Only allow numeric index values
            if ((Test-Numeric $index) -eq $FALSE) {
                continue;
            }
            if ($AverageCalc.ContainsKey([string]$index) -eq $FALSE) {
                $AverageCalc.Add(
                    [string]$index,
                    @{
                        'Interval' = [int]$index;
                        'Time'     = [int]$index * 60;
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

        if (-Not ($IcingaDaemonData.BackgroundDaemon.ServiceCheckScheduler.ContainsKey($CheckCommand))) {
            $IcingaDaemonData.BackgroundDaemon.ServiceCheckScheduler.Add($CheckCommand, [hashtable]::Synchronized(@{}));
            $IcingaDaemonData.BackgroundDaemon.ServiceCheckScheduler[$CheckCommand].Add('results', [hashtable]::Synchronized(@{}));
            $IcingaDaemonData.BackgroundDaemon.ServiceCheckScheduler[$CheckCommand].Add('average', [hashtable]::Synchronized(@{}));
        }

        $LoadedCacheData = Get-IcingaCacheData -Space 'sc_daemon' -CacheStore 'checkresult_store' -KeyName $CheckCommand;

        if ($null -ne $LoadedCacheData) {
            foreach ($entry in $LoadedCacheData.PSObject.Properties) {
                $IcingaDaemonData.BackgroundDaemon.ServiceCheckScheduler[$CheckCommand]['results'].Add(
                    $entry.name,
                    [hashtable]::Synchronized(@{})
                );
                foreach ($item in $entry.Value.PSObject.Properties) {
                    $IcingaDaemonData.BackgroundDaemon.ServiceCheckScheduler[$CheckCommand]['results'][$entry.name].Add(
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

                    Get-IcingaCheckSchedulerPerfData | Out-Null;
                    Get-IcingaCheckSchedulerPluginOutput | Out-Null;

                    $UnixTime = Get-IcingaUnixTime;

                    foreach ($result in $IcingaDaemonData.BackgroundDaemon.ServiceCheckScheduler[$CheckCommand]['results'].Keys) {
                        [string]$HashIndex = $result;
                        $SortedResult = $IcingaDaemonData.BackgroundDaemon.ServiceCheckScheduler[$CheckCommand]['results'][$HashIndex].GetEnumerator() | Sort-Object name -Descending;
                        Add-IcingaHashtableItem -Hashtable $OldData -Key $HashIndex -Value @{} | Out-Null;
                        Add-IcingaHashtableItem -Hashtable $PerfCache -Key $HashIndex -Value @{} | Out-Null;

                        foreach ($timeEntry in $SortedResult) {
                            foreach ($calc in $AverageCalc.Keys) {
                                if (($UnixTime - $AverageCalc[$calc].Time) -le [int]$timeEntry.Key) {
                                    $AverageCalc[$calc].Sum   += $timeEntry.Value;
                                    $AverageCalc[$calc].Count += 1;
                                }
                            }
                            if (($UnixTime - $MaxTimeInSeconds) -le [int]$timeEntry.Key) {
                                Add-IcingaHashtableItem -Hashtable $PerfCache[$HashIndex] -Key ([string]$timeEntry.Key) -Value ([string]$timeEntry.Value) | Out-Null;
                            } else {
                                Add-IcingaHashtableItem -Hashtable $OldData[$HashIndex] -Key $timeEntry -Value $null | Out-Null;
                            }
                        }

                        foreach ($calc in $AverageCalc.Keys) {
                            $AverageValue         = ($AverageCalc[$calc].Sum / $AverageCalc[$calc].Count);
                            [string]$MetricName   = Format-IcingaPerfDataLabel (
                                [string]::Format('{0}_{1}', $HashIndex, $AverageCalc[$calc].Interval)
                            );

                            Add-IcingaHashtableItem `
                                -Hashtable $IcingaDaemonData.BackgroundDaemon.ServiceCheckScheduler[$CheckCommand]['average'] `
                                -Key $MetricName -Value $AverageValue -Override | Out-Null;

                            $AverageCalc[$calc].Sum   = 0;
                            $AverageCalc[$calc].Count = 0;
                        }
                    }

                    # Flush data we no longer require in our cache to free memory
                    foreach ($entry in $OldData.Keys) {
                        foreach ($key in $OldData[$entry].Keys) {
                            Remove-IcingaHashtableItem -Hashtable $IcingaDaemonData.BackgroundDaemon.ServiceCheckScheduler[$CheckCommand]['results'][$entry] -Key $key.Name
                        }
                    }

                    Set-IcingaCacheData -Space 'sc_daemon' -CacheStore 'checkresult' -KeyName $CheckCommand -Value $IcingaDaemonData.BackgroundDaemon.ServiceCheckScheduler[$CheckCommand]['average'];
                    # Write collected metrics to disk in case we reload the daemon. We will load them back into the module after reload then
                    Set-IcingaCacheData -Space 'sc_daemon' -CacheStore 'checkresult_store' -KeyName $CheckCommand -Value $PerfCache;
                } catch {
                    # Todo: Add error reporting / handling
                }

                $PassedTime   = 0;
                $SortedResult.Clear();
                $OldData.Clear();
                $PerfCache.Clear();
            }
            $PassedTime += 1;
            Start-Sleep -Seconds 1;
        }
    };

    New-IcingaThreadInstance -Name $ThreadName -ThreadPool $IcingaDaemonData.IcingaThreadPool.ServiceCheckPool -ScriptBlock $ScriptBlock -Arguments @( $global:IcingaDaemonData, $CheckCommand, $Arguments, $Interval, $TimeIndexes, $CheckId ) -Start;
}
