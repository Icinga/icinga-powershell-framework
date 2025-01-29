function Write-IcingaPluginPerfData()
{
    # We shouldn't write all Metrics over Time to Icinga, as this will just cause a massive
    # overload of Performance Metrics written and processed. We leave this code for now
    # allowing us to enable it later again or make it user configurable
    #[string]$MetricsOverTime = Get-IcingaMetricsOverTimePerfData -AddWhiteSpace;
    [string]$MetricsOverTime = '';

    if ($Global:Icinga.Protected.RunAsDaemon -eq $FALSE -And $Global:Icinga.Protected.JEAContext -eq $FALSE) {
        if ($Global:Icinga.Private.Scheduler.PerfDataWriter.Storage.Length -ne 0) {
            Write-IcingaConsolePlain ([string]::Format('| {0}{1}', ($Global:Icinga.Private.Scheduler.PerfDataWriter.Storage.ToString()), $MetricsOverTime));
        }
    } else {
        $Global:Icinga.Private.Scheduler.PerformanceData = $Global:Icinga.Private.Scheduler.PerfDataWriter.Storage.ToString() + $MetricsOverTime;
    }

    # Ensure we clear our cache after writing the data
    $Global:Icinga.Private.Scheduler.PerfDataWriter.Cache.Clear() | Out-Null;
    $Global:Icinga.Private.Scheduler.PerfDataWriter.Storage.Clear() | Out-Null;
}
