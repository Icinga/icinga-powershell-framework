function Get-IcingaCheckSchedulerPerfData()
{
    if ($null -eq $IcingaDaemonData) {
        return $null;
    }

    if ($IcingaDaemonData.ContainsKey('IcingaThreadContent') -eq $FALSE) {
        return $null;
    }

    if ($IcingaDaemonData.IcingaThreadContent.ContainsKey('Scheduler') -eq $FALSE) {
        return $null;
    }

    if ($IcingaDaemonData.IcingaThreadContent.Scheduler.ContainsKey('PluginPerfData') -eq $FALSE) {
        return $null;
    }

    $PerfData = $IcingaDaemonData.IcingaThreadContent.Scheduler.PluginPerfData;
    $IcingaDaemonData.IcingaThreadContent.Scheduler.PluginPerfData = @();

    return $PerfData;
}
