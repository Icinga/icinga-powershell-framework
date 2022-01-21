function Start-IcingaPowerShellDaemon()
{
    param (
        [switch]$RunAsService = $FALSE,
        [switch]$JEARestart   = $FALSE
    );

    $global:IcingaDaemonData.FrameworkRunningAsDaemon = $TRUE;

    [string]$MainServicePidFile                                           = (Join-Path -Path (Get-IcingaCacheDir) -ChildPath 'service.pid');
    [string]$JeaPidFile                                                   = (Join-Path -Path (Get-IcingaCacheDir) -ChildPath 'jea.pid');
    [string]$JeaProfile                                                   = Get-IcingaPowerShellConfig -Path 'Framework.JEAProfile';
    [Security.Cryptography.X509Certificates.X509Certificate2]$Certificate = Get-IcingaForWindowsCertificate;
    [string]$JeaPid                                                       = '';

    if (Test-IcingaJEAServiceRunning) {
        Write-IcingaEventMessage -EventId 1503 -Namespace 'Framework';
        exit 1;
    }

    Write-IcingaFileSecure -File ($MainServicePidFile) -Value $PID;

    if ([string]::IsNullOrEmpty($JeaProfile)) {
        Write-IcingaDebugMessage -Message 'Starting Icinga for Windows service without JEA context' -Objects $RunAsService, $JEARestart, $JeaProfile;

        $global:IcingaDaemonData.FrameworkRunningAsDaemon = $TRUE;
        $global:IcingaDaemonData.Add('BackgroundDaemon', [hashtable]::Synchronized(@{ }));
        # Todo: Add config for active background tasks. Set it to 20 for the moment
        $global:IcingaDaemonData.IcingaThreadPool.Add('BackgroundPool', (New-IcingaThreadPool -MaxInstances 20));
        $global:IcingaDaemonData.Add('SSLCertificate', $Certificate);

        New-IcingaThreadInstance -Name "Icinga_PowerShell_Background_Daemon" -ThreadPool $IcingaDaemonData.IcingaThreadPool.BackgroundPool -Command 'Add-IcingaForWindowsDaemon' -CmdParameters @{ 'IcingaDaemonData' = $global:IcingaDaemonData } -Start;
    } else {
        Write-IcingaDebugMessage -Message 'Starting Icinga for Windows service inside JEA context' -Objects $RunAsService, $JEARestart, $JeaProfile;
        & powershell.exe -NoProfile -NoLogo -ConfigurationName $JeaProfile -Command {
            try {
                Use-Icinga -Daemon;

                Write-IcingaFileSecure -File ($args[1]) -Value $PID;

                $Global:IcingaDaemonData.JEAContext               = $TRUE;
                $global:IcingaDaemonData.FrameworkRunningAsDaemon = $TRUE;
                $global:IcingaDaemonData.Add('BackgroundDaemon', [hashtable]::Synchronized(@{ }));
                # Todo: Add config for active background tasks. Set it to 20 for the moment
                $global:IcingaDaemonData.IcingaThreadPool.Add('BackgroundPool', (New-IcingaThreadPool -MaxInstances 20));
                $global:IcingaDaemonData.Add('SSLCertificate', ($args[0]));

                New-IcingaThreadInstance -Name "Icinga_PowerShell_Background_Daemon" -ThreadPool $IcingaDaemonData.IcingaThreadPool.BackgroundPool -Command 'Add-IcingaForWindowsDaemon' -CmdParameters @{ 'IcingaDaemonData' = $global:IcingaDaemonData } -Start;

                while ($TRUE) {
                    Start-Sleep -Seconds 100;
                }
            } catch {
                $CallStack = @();
                foreach ($entry in (Get-PSCallStack)) {
                    $CallStack += [string]::Format('{0} => Line {1}', $entry.FunctionName, $entry.ScriptLineNumber);
                }
                Write-IcingaEventMessage -EventId 1600 -Namespace Framework -Objects $_.Exception.Message, $_.Exception.StackTrace, $CallStack;
            }
        } -Args $Certificate, $JeaPidFile;
    }

    if ($JEARestart) {
        return;
    }

    if ($RunAsService) {
        [int]$JeaRestartCounter = 1;
        while ($TRUE) {
            if ([string]::IsNullOrEmpty($JeaProfile) -eq $FALSE) {
                if ([string]::IsNullOrEmpty($JeaPid)) {
                    [string]$JeaPid = Get-IcingaJEAServicePid;
                }

                if ((Test-IcingaJEAServiceRunning -JeaPid $JeaPid) -eq $FALSE) {
                    if ($JeaRestartCounter -gt 5) {
                        Write-IcingaEventMessage -EventId 1504 -Namespace Framework;
                        exit 1;
                    }

                    Write-IcingaFileSecure -File $JeaPidFile -Value '';
                    Write-IcingaEventMessage -EventId 1505 -Namespace Framework -Objects ([string]::Format('{0}/5', $JeaRestartCounter));
                    Start-IcingaPowerShellDaemon -RunAsService:$RunAsService -JEARestart;

                    $JeaRestartCounter += 1;
                    $JeaPid = '';
                }

                Start-Sleep -Seconds 5;
                continue;
            }
            Start-Sleep -Seconds 100;
        }
    }
}
