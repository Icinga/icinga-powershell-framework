function Remove-IcingaThread()
{
    param(
        [string]$Thread
    );

    if ([string]::IsNullOrEmpty($Thread)) {
        return;
    }

    Stop-IcingaThread -Thread $Thread;

    if ($global:IcingaDaemonData.IcingaThreads.ContainsKey($Thread)) {
        $global:IcingaDaemonData.IcingaThreads[$Thread].Shell.Dispose();
        $global:IcingaDaemonData.IcingaThreads.Remove($Thread);
    }
}
