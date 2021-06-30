<#
.SYNOPSIS
   A background daemon executing registered service checks in the background to fetch
   metrics for certain checks over time. Time frames are configurable individual
.DESCRIPTION
   This background daemon will execute checks registered with "Register-IcingaServiceCheck"
   for the given time interval and store the collected metrics for a defined period of time
   inside a JSON file. Check values collected by this daemon are then automatically added
   to regular check executions for additional performance metrics.

   Example: Register-IcingaServiceCheck -CheckCommand 'Invoke-IcingaCheckCPU' -Interval 30 -TimeIndexes 1,3,5,15;

   This will execute the CPU check every 30 seconds and calculate the average of 1, 3, 5 and 15 minutes

   More Information on
   https://icinga.com/docs/icinga-for-windows/latest/doc/service/02-Register-Daemons/
   https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function Start-IcingaServiceCheckDaemon()
{
    $ScriptBlock = {
        param($IcingaDaemonData);

        Use-Icinga -LibOnly -Daemon;

        $IcingaDaemonData.IcingaThreadPool.Add('ServiceCheckPool', (New-IcingaThreadPool -MaxInstances (Get-IcingaConfigTreeCount -Path 'BackgroundDaemon.RegisteredServices')));

        while ($TRUE) {

            $RegisteredServices = Get-IcingaRegisteredServiceChecks;

            foreach ($service in $RegisteredServices.Keys) {
                [string]$ThreadName = [string]::Format('Icinga_Background_Service_Check_{0}', $service);
                if ((Test-IcingaThread $ThreadName)) {
                    continue;
                }

                [hashtable]$ServiceArgs = @{ };

                if ($null -ne $RegisteredServices[$service].Arguments) {
                    foreach ($property in $RegisteredServices[$service].Arguments.PSObject.Properties) {
                        if ($ServiceArgs.ContainsKey($property.Name)) {
                            continue;
                        }

                        $ServiceArgs.Add($property.Name, $property.Value)
                    }
                }

                Start-IcingaServiceCheckTask -CheckId $service -CheckCommand $RegisteredServices[$service].CheckCommand -Arguments $ServiceArgs -Interval $RegisteredServices[$service].Interval -TimeIndexes $RegisteredServices[$service].TimeIndexes;
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
    };

    New-IcingaThreadInstance -Name $ThreadName -ThreadPool $IcingaDaemonData.IcingaThreadPool.ServiceCheckPool -ScriptBlock $ScriptBlock -Arguments @( $global:IcingaDaemonData, $CheckCommand, $Arguments, $Interval, $TimeIndexes, $CheckId ) -Start;
}
