function Start-IcingaPowerShellDaemon()
{
    $ScriptBlock = {
        param($IcingaDaemonData);

        Use-Icinga -LibOnly -Daemon;

        try {
            $EnabledDaemons = Get-IcingaBackgroundDaemons;
            
            foreach ($daemon in $EnabledDaemons.Keys) {
                if (-Not (Test-IcingaFunction $daemon)) {
                    continue;
                }

                $daemonArgs = $EnabledDaemons[$daemon];
                &$daemon @daemonArgs;
            }
        } catch {
            # Todo: Add exception handling
        }

        while ($TRUE) {
            Start-Sleep -Seconds 1;
        }
    };

    $global:IcingaDaemonData.FrameworkRunningAsDaemon = $TRUE;
    $global:IcingaDaemonData.Add('BackgroundDaemon', [hashtable]::Synchronized(@{}));
    # Todo: Add config for active background tasks. Set it to 20 for the moment
    $global:IcingaDaemonData.IcingaThreadPool.Add('BackgroundPool', (New-IcingaThreadPool -MaxInstances 20));
    $global:IcingaDaemonData.Add('Config', (Read-IcingaPowerShellConfig));

    New-IcingaThreadInstance -Name "Icinga_PowerShell_Background_Daemon" -ThreadPool $IcingaDaemonData.IcingaThreadPool.BackgroundPool -ScriptBlock $ScriptBlock -Arguments @( $global:IcingaDaemonData ) -Start;
}
