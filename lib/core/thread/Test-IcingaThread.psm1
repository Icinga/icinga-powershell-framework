function Test-IcingaThread()
{
    param(
        [string]$Thread
    );

    if ([string]::IsNullOrEmpty($Thread)) {
        return $FALSE;
    }

    return $Global:Icinga.Public.Threads.ContainsKey($Thread);
}
