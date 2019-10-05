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
        $PassedTime = 0;

        if (-Not ($IcingaDaemonData.BackgroundDaemon.ServiceCheckScheduler.ContainsKey($CheckCommand))) {
            $IcingaDaemonData.BackgroundDaemon.ServiceCheckScheduler.Add($CheckCommand, [hashtable]::Synchronized(@{}));
            $IcingaDaemonData.BackgroundDaemon.ServiceCheckScheduler[$CheckCommand].Add('results', [hashtable]::Synchronized(@{}));
            $IcingaDaemonData.BackgroundDaemon.ServiceCheckScheduler[$CheckCommand].Add('average', [hashtable]::Synchronized(@{}));
        }

        while ($TRUE) {
            if ($PassedTime -ge $Interval) {
                & $CheckCommand @Arguments;

                $Results  = $IcingaDaemonData.BackgroundDaemon.ServiceCheckScheduler[$CheckCommand]['results'];
                $UnixTime = Get-IcingaUnixTime;
                $OldData  = @{};

                foreach ($result in $Results.Keys) {
                    $SortedResult = $Results[$result].GetEnumerator() | Sort-Object name -Descending;
                    Add-IcingaHashtableItem -Hashtable $OldData -Key $result -Value @{};

                    foreach ($index in $TimeIndexes) {
                        $ObjectCount   = 0;
                        $ObjectValue   = 0;
                        $TimeInSeconds = $index * 60;

                        foreach ($timeEntry in $SortedResult) {
                            if (($UnixTime - $TimeInSeconds) -le [int]$timeEntry.Key) {
                                $ObjectCount += 1;
                                $ObjectValue += $timeEntry.Value;
                                Remove-IcingaHashtableItem -Hashtable $OldData[$result] -Key $timeEntry;
                            } else {
                                Add-IcingaHashtableItem -Hashtable $OldData[$result] -Key $timeEntry -Value $TRUE;
                            }
                        }

                        $AvarageValue = ($ObjectValue / $ObjectCount);
                        $MetricName   = [string]::Format('{0}_{1}', $result, $index);

                        Add-IcingaHashtableItem `
                            -Hashtable $IcingaDaemonData.BackgroundDaemon.ServiceCheckScheduler[$CheckCommand]['average'] `
                            -Key (Format-IcingaPerfDataLabel $MetricName) -Value $AvarageValue -Override;
                    }
                }

                # Flush data we no longer require in our cache to free memory
                foreach ($entry in $OldData.Keys) {
                    foreach ($key in $OldData[$entry].Keys) {
                        Remove-IcingaHashtableItem -Hashtable $Results[$entry] -Key $key.Name
                    }
                }

                Set-IcingaCacheData -Space 'sc_daemon' -CacheStore 'checkresult' -KeyName $CheckCommand -Value $IcingaDaemonData.BackgroundDaemon.ServiceCheckScheduler[$CheckCommand]['average'];

                $PassedTime = 0;
            }
            $PassedTime += 1;
            Start-Sleep -Seconds 1;
        }
    };

    New-IcingaThreadInstance -Name $ThreadName -ThreadPool $IcingaDaemonData.IcingaThreadPool.ServiceCheckPool -ScriptBlock $ScriptBlock -Arguments @( $global:IcingaDaemonData, $CheckCommand, $Arguments, $Interval, $TimeIndexes, $CheckId ) -Start;
}
