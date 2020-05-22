function New-IcingaCheckSchedulerEnvironment()
{
    $IcingaDaemonData.IcingaThreadContent.Add('Scheduler', @{ });
    if ($IcingaDaemonData.IcingaThreadContent['Scheduler'].ContainsKey('PluginCache') -eq $FALSE) {
        $IcingaDaemonData.IcingaThreadContent['Scheduler'].Add('PluginCache', @());
        $IcingaDaemonData.IcingaThreadContent['Scheduler'].Add('PluginPerfData', @());
    }
}
