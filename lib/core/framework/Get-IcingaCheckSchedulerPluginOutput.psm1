function Get-IcingaCheckSchedulerPluginOutput()
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

    if ($IcingaDaemonData.IcingaThreadContent.Scheduler.ContainsKey('PluginCache') -eq $FALSE) {
        return $null;
    }

    $CheckResult = [string]::Join("`r`n", $IcingaDaemonData.IcingaThreadContent.Scheduler.PluginCache);
    $IcingaDaemonData.IcingaThreadContent.Scheduler.PluginCache = @();
    
    return $CheckResult;
}
