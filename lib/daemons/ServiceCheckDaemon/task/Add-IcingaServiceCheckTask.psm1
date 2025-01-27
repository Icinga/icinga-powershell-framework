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

    $MetricCacheFile           = Join-Path -Path (Join-Path -Path (Join-Path -Path (Get-IcingaCacheDir) -ChildPath 'service_check_cache') -ChildPath 'metrics') -ChildPath ([string]::Format('{0}.xml', $CheckCommand));
    [int]$CheckInterval        = ConvertTo-Seconds $Interval;
    [hashtable]$CheckDataCache = @{ };
    [array]$PerfDataEntries    = @();

    if (Test-Path -Path $MetricCacheFile) {
        $CheckDataCache = [System.Management.Automation.PSSerializer]::Deserialize((Get-Content -Path $MetricCacheFile -Raw -Encoding UTF8));
    }

    while ($TRUE) {
        if ($Global:Icinga.Private.Daemons.ServiceCheck.PassedTime -lt $CheckInterval) {
            $Global:Icinga.Private.Daemons.ServiceCheck.PassedTime += 1;
            Start-Sleep -Seconds 1;

            continue;
        }

        $Global:Icinga.Private.Daemons.ServiceCheck.PassedTime = 0;

        # Clear possible previous performance data from the daemon cache
        $Global:Icinga.Private.Scheduler.PerfDataWriter.Daemon.Clear();

        # Execute our check with possible arguments
        try {
            & $CheckCommand @Arguments | Out-Null;
        } catch {
            Write-IcingaEventMessage -EventId 1451 -Namespace 'Framework' -ExceptionObject $_ -Objects $CheckCommand, ($Arguments | Out-String), (Get-IcingaInternalPluginOutput);

            Clear-IcingaCheckSchedulerEnvironment;

            # Force Icinga for Windows Garbage Collection
            Optimize-IcingaForWindowsMemory -ClearErrorStack -SmartGC;

            continue;
        }

        $UnixTime = Get-IcingaUnixTime;

        foreach ($PerfLabel in $Global:Icinga.Private.Scheduler.PerfDataWriter.Daemon.Keys) {
            $PerfValue = $Global:Icinga.Private.Scheduler.PerfDataWriter.Daemon[$PerfLabel].Value;
            $PerfUnit  = $Global:Icinga.Private.Scheduler.PerfDataWriter.Daemon[$PerfLabel].Unit;

            if ($CheckDataCache.ContainsKey($PerfLabel) -eq $FALSE) {
                $CheckDataCache.Add($PerfLabel, (New-Object System.Collections.ArrayList));
            }

            $CheckDataCache[$PerfLabel].Add(
                @{
                    'Time'  = $UnixTime;
                    'Value' = $PerfValue;
                    'Unit'  = $PerfUnit;
                }
            ) | Out-Null;

            [int]$IndexCount = $CheckDataCache[$PerfLabel].Count;
            for ($i = 0; $i -lt $IndexCount; $i++) {
                # In case we store more values than we require for our max time range, remove the oldest one
                if (($UnixTime - $Global:Icinga.Private.Daemons.ServiceCheck.MaxTimeInSeconds) -gt [int]($CheckDataCache[$PerfLabel][$i].Time)) {
                    $CheckDataCache[$PerfLabel].RemoveAt($i) | Out-Null;
                    $i--;
                    $IndexCount--;
                    continue;
                }

                # Calculate the average value for our performance data based on the remaining data
                foreach ($calc in $Global:Icinga.Private.Daemons.ServiceCheck.AverageCalculation.Keys) {
                    if (($UnixTime - $Global:Icinga.Private.Daemons.ServiceCheck.AverageCalculation[$calc].Time) -le [int]($CheckDataCache[$PerfLabel][$i].Time)) {
                        $Global:Icinga.Private.Daemons.ServiceCheck.AverageCalculation[$calc].Sum   += $CheckDataCache[$PerfLabel][$i].Value;
                        $Global:Icinga.Private.Daemons.ServiceCheck.AverageCalculation[$calc].Count += 1;
                    }
                }
            }

            # Now calculate the average values for our performance data
            foreach ($calc in $Global:Icinga.Private.Daemons.ServiceCheck.AverageCalculation.Keys) {
                if ($Global:Icinga.Private.Daemons.ServiceCheck.AverageCalculation[$calc].Count -ne 0) {
                    $AverageValue            = ($Global:Icinga.Private.Daemons.ServiceCheck.AverageCalculation[$calc].Sum / $Global:Icinga.Private.Daemons.ServiceCheck.AverageCalculation[$calc].Count);
                    [string]$MetricMultiName = [string]::Format('{0}::Interval{1}={2}{3}', $PerfLabel, $Global:Icinga.Private.Daemons.ServiceCheck.AverageCalculation[$calc].Time, (Format-IcingaPerfDataValue $AverageValue), $PerfUnit);
                    # Write our  performance data label
                    $PerfDataEntries        += $MetricMultiName;
                }

                $Global:Icinga.Private.Daemons.ServiceCheck.AverageCalculation[$calc].Sum   = 0;
                $Global:Icinga.Private.Daemons.ServiceCheck.AverageCalculation[$calc].Count = 0;
            }
        }

        $Global:Icinga.Public.Daemons.ServiceCheck.PerformanceDataCache[$CheckCommand] = $PerfDataEntries -Join ' ';
        $PerfDataEntries = @();

        $PerformanceLabelFile = Join-Path -Path (Join-Path -Path (Join-Path -Path (Get-IcingaCacheDir) -ChildPath 'service_check_cache') -ChildPath 'performance_labels') -ChildPath ([string]::Format('{0}.db', $CheckCommand));
        $CheckCacheXMLObj     = [System.Management.Automation.PSSerializer]::Serialize($CheckDataCache);

        if ((Test-Path -Path $PerformanceLabelFile) -eq $FALSE) {
            New-Item -Path $PerformanceLabelFile -ItemType File -Force | Out-Null;
        }
        if ((Test-Path -Path $MetricCacheFile) -eq $FALSE) {
            New-Item -Path $MetricCacheFile -ItemType File -Force | Out-Null;
        }

        Set-Content -Path $PerformanceLabelFile -Value $Global:Icinga.Public.Daemons.ServiceCheck.PerformanceDataCache[$CheckCommand] -Force -Encoding UTF8;
        Set-Content -Path $MetricCacheFile      -Value $CheckCacheXMLObj -Force -Encoding UTF8;
    }
}
