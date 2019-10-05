function Start-IcingaThread()
{
    param(
        [string]$Thread
    );

    if ([string]::IsNullOrEmpty($Thread)) {
        return;
    }

    if ($global:IcingaDaemonData.IcingaThreads.ContainsKey($Thread)) {
        if ($global:IcingaDaemonData.IcingaThreads[$Thread].Started -eq $FALSE) {
            $global:IcingaDaemonData.IcingaThreads[$Thread].Handle = $global:IcingaDaemonData.IcingaThreads[$Thread].Shell.BeginInvoke();
            $global:IcingaDaemonData.IcingaThreads[$Thread].Started = $TRUE;
        }
    }
}
