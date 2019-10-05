function Write-IcingaPluginOutput()
{
    param(
        $Output
    );

    if ($global:IcingaDaemonData.FrameworkRunningAsDaemon -eq $FALSE) {
        Write-Host $Output;
    } else {
        $IcingaThreadContent['Scheduler']['PluginCache'] += $Output;
    }
}
