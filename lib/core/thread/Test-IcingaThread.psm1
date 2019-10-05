function Test-IcingaThread()
{
    param(
        [string]$Thread
    );

    if ([string]::IsNullOrEmpty($Thread)) {
        return $FALSE;
    }

    return $global:IcingaDaemonData.IcingaThreads.ContainsKey($Thread);
}
