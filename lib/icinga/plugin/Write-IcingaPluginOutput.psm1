function Write-IcingaPluginOutput()
{
    param(
        $Output
    );

    if ($global:IcingaDaemonData.FrameworkRunningAsDaemon -eq $FALSE) {
        Write-Host $Output;
    } else {
        if ($global:IcingaDaemonData.IcingaThreadContent.ContainsKey('Scheduler')) {
            $global:IcingaDaemonData.IcingaThreadContent['Scheduler']['PluginCache'] += $Output;
        }
    }
}
