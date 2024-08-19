function Write-IcingaPluginPerfData()
{
    if ($Global:Icinga.Protected.RunAsDaemon -eq $FALSE -And $Global:Icinga.Protected.JEAContext -eq $FALSE) {
        if ($Global:Icinga.Private.Scheduler.PerfDataWriter.Storage.Length -ne 0) {
            Write-IcingaConsolePlain ([string]::Format('| {0}', ($Global:Icinga.Private.Scheduler.PerfDataWriter.Storage.ToString())));
        }
    } else {
        $Global:Icinga.Private.Scheduler.PerformanceData = $Global:Icinga.Private.Scheduler.PerfDataWriter.Storage.ToString();
    }

    # Ensure we clear our cache after writing the data
    $Global:Icinga.Private.Scheduler.PerfDataWriter.Cache.Clear() | Out-Null;
    $Global:Icinga.Private.Scheduler.PerfDataWriter.Storage.Clear() | Out-Null;
}
