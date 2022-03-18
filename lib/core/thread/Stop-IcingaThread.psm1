function Stop-IcingaThread()
{
    param (
        [string]$Thread = ''
    );

    if ([string]::IsNullOrEmpty($Thread)) {
        return;
    }

    if ($Global:Icinga.Public.Threads.ContainsKey($Thread)) {
        if ($Global:Icinga.Public.Threads[$Thread].Started -eq $TRUE) {
            $Global:Icinga.Public.Threads[$Thread].Shell.Stop();
            $Global:Icinga.Public.Threads[$Thread].Handle  = $null;
            $Global:Icinga.Public.Threads[$Thread].Started = $FALSE;
        }
    }
}
