function Add-IcingaForWindowsDaemon()
{
    try {
        $EnabledDaemons = Get-IcingaBackgroundDaemons;

        foreach ($daemon in $EnabledDaemons.Keys) {
            Write-IcingaDebugMessage -Message 'Trying to enable background daemon' -Objects $daemon;
            if (-Not (Test-IcingaFunction $daemon)) {
                Write-IcingaEventMessage -EventId 1400 -Namespace 'Framework' $daemon;
                continue;
            }

            $daemonArgs = $EnabledDaemons[$daemon];
            Write-IcingaDebugMessage -Message 'Starting background daemon' -Objects $daemon, $daemonArgs;

            & $daemon @daemonArgs;
        }
    } catch {
        # Todo: Add exception handling
    }

    while ($TRUE) {
        Start-Sleep -Seconds 10;

        # Handle possible threads being frozen
        Suspend-IcingaForWindowsFrozenThreads;

        # Force Icinga for Windows Garbage Collection
        Optimize-IcingaForWindowsMemory -ClearErrorStack -SmartGC;
    }
}
