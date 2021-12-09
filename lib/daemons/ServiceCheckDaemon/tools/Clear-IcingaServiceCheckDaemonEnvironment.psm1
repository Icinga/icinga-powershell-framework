function Clear-IcingaServiceCheckDaemonEnvironment()
{
    $Global:Icinga.Private.Daemons.ServiceCheck.PassedTime = 0;
    $Global:Icinga.Private.Daemons.ServiceCheck.SortedResult.Clear();
    $Global:Icinga.Private.Daemons.ServiceCheck.PerformanceCache.Clear();
}
