function Restart-IcingaThread()
{
    param(
        [string]$Thread
    );

    if ([string]::IsNullOrEmpty($Thread)) {
        return;
    }

    Stop-IcingaThread $Thread;
    Start-IcingaThread $Thread;
}
