function Stop-IcingaThread()
{
    param(
        [string]$Thread
    );

    if ([string]::IsNullOrEmpty($Thread)) {
        return;
    }

    if ($global:IcingaDaemonData.IcingaThreads.ContainsKey($Thread)) {
        if ($global:IcingaDaemonData.IcingaThreads[$Thread].Started -eq $TRUE) {
            $global:IcingaDaemonData.IcingaThreads[$Thread].Shell.Stop();
            $global:IcingaDaemonData.IcingaThreads[$Thread].Handle  = $null;
            $global:IcingaDaemonData.IcingaThreads[$Thread].Started = $FALSE;
        }
    }
}
