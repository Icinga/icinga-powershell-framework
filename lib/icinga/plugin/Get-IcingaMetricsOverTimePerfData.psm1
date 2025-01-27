function Get-IcingaMetricsOverTimePerfData()
{
    param (
        [switch]$AddWhiteSpace = $FALSE
    );

    [string]$MetricsOverTime = '';
    [bool]$IsDaemonWorker    = $FALSE;

    if ([string]::IsNullOrEmpty($Global:Icinga.Private.Scheduler.PerfDataWriter.MetricsOverTime) -eq $FALSE) {
        if ($AddWhiteSpace) {
            return (' ' + $Global:Icinga.Private.Scheduler.PerfDataWriter.MetricsOverTime);
        }

        return $Global:Icinga.Private.Scheduler.PerfDataWriter.MetricsOverTime;
    }

    if ($Global:Icinga.Public.Daemons.ContainsKey('ServiceCheck') -And $Global:Icinga.Public.Daemons.ServiceCheck.ContainsKey('PerformanceDataCache') -And $Global:Icinga.Public.Daemons.ServiceCheck.PerformanceDataCache.ContainsKey($Global:Icinga.Private.Scheduler.CheckCommand)) {
        $IsDaemonWorker = $TRUE;
    }

    if ($IsDaemonWorker) {
        $MetricsOverTime = $Global:Icinga.Public.Daemons.ServiceCheck.PerformanceDataCache[$Global:Icinga.Private.Scheduler.CheckCommand];
    } else {
        $PerformanceLabelFile = Join-Path -Path (Join-Path -Path (Join-Path -Path (Get-IcingaCacheDir) -ChildPath 'service_check_cache') -ChildPath 'performance_labels') -ChildPath ([string]::Format('{0}.db', $Global:Icinga.Private.Scheduler.CheckCommand));
        if (Test-Path -Path $PerformanceLabelFile) {
            $MetricsOverTime = Get-Content -Path $PerformanceLabelFile -Raw;
        }
    }

    $Global:Icinga.Private.Scheduler.PerfDataWriter.MetricsOverTime = $MetricsOverTime;

    if ([string]::IsNullOrEmpty($MetricsOverTime) -eq $FALSE -And $AddWhiteSpace) {
        $MetricsOverTime = ' ' + $MetricsOverTime;
    }

    return $MetricsOverTime;
}
