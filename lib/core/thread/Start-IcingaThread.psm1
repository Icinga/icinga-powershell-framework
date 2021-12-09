function Start-IcingaThread()
{
    param(
        [string]$Thread
    );

    if ([string]::IsNullOrEmpty($Thread)) {
        return;
    }

    if ($Global:Icinga.Public.Threads.ContainsKey($Thread)) {
        if ($Global:Icinga.Public.Threads[$Thread].Started -eq $FALSE) {
            $Global:Icinga.Public.Threads[$Thread].Handle = $Global:Icinga.Public.Threads[$Thread].Shell.BeginInvoke();
            $Global:Icinga.Public.Threads[$Thread].Started = $TRUE;
        }
    }
}
