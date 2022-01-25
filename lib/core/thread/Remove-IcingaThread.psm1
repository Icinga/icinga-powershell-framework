function Remove-IcingaThread()
{
    param(
        [string]$Thread
    );

    if ([string]::IsNullOrEmpty($Thread)) {
        return;
    }

    Stop-IcingaThread -Thread $Thread;

    if ($Global:Icinga.Public.Threads.ContainsKey($Thread)) {
        $Global:Icinga.Public.Threads[$Thread].Shell.Dispose();
        $Global:Icinga.Public.Threads.Remove($Thread);

        Write-IcingaDebugMessage 'Removing Thread: {0}' -Objects $Thread;
    }
}
