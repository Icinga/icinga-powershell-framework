function Suspend-IcingaForWindowsFrozenThreads()
{
    try {
        [array]$ConfiguredThreads = $Global:Icinga.Public.ThreadAliveHousekeeping.Keys;

        foreach ($thread in $ConfiguredThreads) {
            $ThreadConfig = $Global:Icinga.Public.ThreadAliveHousekeeping[$thread];

            # Only check active threads
            if ($ThreadConfig.Active -eq $FALSE) {
                continue;
            }

            # Check if the thread is active and not doing something for 5 minutes
            if (([DateTime]::Now - $ThreadConfig.LastSeen).TotalSeconds -lt $ThreadConfig.Timeout) {
                continue;
            }

            # If it does, kill the thread
            Remove-IcingaThread -Thread $thread;

            if ($ThreadConfig.TerminateAction.Count -ne 0) {
                $TerminateArguments = @{ };
                if ($ThreadConfig.TerminateAction.ContainsKey('Arguments')) {
                    $TerminateArguments = $ThreadConfig.TerminateAction.Arguments;
                }

                if ($ThreadConfig.TerminateAction.ContainsKey('Command')) {
                    $TerminateCmd = $ThreadConfig.TerminateAction.Command;

                    if ([string]::IsNullOrEmpty($TerminateCmd) -eq $FALSE) {
                        & $TerminateCmd @TerminateArguments | Out-Null;
                    }
                }
            }

            # Now restart it
            New-IcingaThreadInstance `
                -ThreadName $thread `
                -ThreadPool $ThreadConfig.ThreadPool `
                -Command $ThreadConfig.Command `
                -CmdParameters $ThreadConfig.Arguments `
                -Start `
                -CheckAliveState;

            Write-IcingaEventMessage -EventId 1507 -Namespace 'Framework' -Objects $thread;
        }
    } catch {
        # Nothing to do here
    }
}
