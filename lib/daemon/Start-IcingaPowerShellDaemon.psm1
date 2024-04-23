function Start-IcingaPowerShellDaemon()
{
    param (
        [switch]$RunAsService = $FALSE,
        [switch]$JEAContext   = $FALSE,
        [switch]$JEARestart   = $FALSE
    );

    Start-IcingaForWindowsDaemon -RunAsService:$RunAsService -JEARestart:$JEARestart -JEAContext:$JEAContext;
}

function Start-IcingaForWindowsDaemon()
{
    param (
        [switch]$RunAsService = $FALSE,
        [switch]$JEAContext   = $FALSE,
        [switch]$JEARestart   = $FALSE
    );

    $Global:Icinga.Protected.RunAsDaemon                                  = [bool]$RunAsService;
    $Global:Icinga.Protected.JEAContext                                   = [bool]$JEAContext;
    [string]$MainServicePidFile                                           = (Join-Path -Path (Get-IcingaCacheDir) -ChildPath 'service.pid');
    [string]$JeaPidFile                                                   = (Join-Path -Path (Get-IcingaCacheDir) -ChildPath 'jea.pid');
    [string]$JeaProfile                                                   = Get-IcingaPowerShellConfig -Path 'Framework.JEAProfile';
    [string]$JeaPid                                                       = '';

    if (Test-IcingaJEAServiceRunning) {
        Write-IcingaEventMessage -EventId 1503 -Namespace 'Framework';
        exit 1;
    }

    Write-IcingaFileSecure -File ($MainServicePidFile) -Value $PID;

    if ([string]::IsNullOrEmpty($JeaProfile)) {
        Write-IcingaDebugMessage -Message 'Starting Icinga for Windows service without JEA context' -Objects $RunAsService, $JEARestart, $JeaProfile;

        # Todo: Add config for active background tasks. Set it to 20 for the moment
        Add-IcingaThreadPool -Name 'MainPool' -MaxInstances 20;
        $Global:Icinga.Public.Add(
            'SSL',
            @{
                'Certificate'    = $null;
                'CertFile'       = $null;
                'CertThumbprint' = $null;
                'CertFilter'     = $null;
            }
        );

        New-IcingaThreadInstance -Name "Main" -ThreadPool (Get-IcingaThreadPool -Name 'MainPool') -Command 'Add-IcingaForWindowsDaemon' -Start;
    } else {
        Write-IcingaDebugMessage -Message 'Starting Icinga for Windows service inside JEA context' -Objects $RunAsService, $JEARestart, $JeaProfile;

        & powershell.exe -NoProfile -NoLogo -ConfigurationName $JeaProfile -Command {
            try {
                Use-Icinga -Daemon;

                Write-IcingaFileSecure -File ($args[0]) -Value $PID;

                $Global:Icinga.Protected.JEAContext  = $TRUE;
                $Global:Icinga.Protected.RunAsDaemon = $TRUE;
                # Todo: Add config for active background tasks. Set it to 20 for the moment
                Add-IcingaThreadPool -Name 'MainPool' -MaxInstances 20;
 
                $Global:Icinga.Public.Add(
                    'SSL',
                    @{
                        'Certificate'    = $null;
                        'CertFile'       = $null;
                        'CertThumbprint' = $null;
                        'CertFilter'     = $null;
                    }
                );

                New-IcingaThreadInstance -Name "Main" -ThreadPool (Get-IcingaThreadPool -Name 'MainPool') -Command 'Add-IcingaForWindowsDaemon' -Start;

                while ($TRUE) {
                    Start-Sleep -Seconds 100;
                }
            } catch {
                Write-IcingaEventMessage -EventId 1600 -Namespace 'Framework' -ExceptionObject $_;
            }
        } -Args $JeaPidFile;
    }

    if ($JEARestart) {
        return;
    }

    if ($RunAsService) {
        [int]$JeaRestartCounter = 1;
        $FailureTime            = $null;
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
                    $FailureTime = [DateTime]::Now;
                    Write-IcingaEventMessage -EventId 1505 -Namespace Framework -Objects ([string]::Format('{0}/5', $JeaRestartCounter));
                    Start-IcingaForWindowsDaemon -RunAsService:$RunAsService -JEAContext:$JEAContext -JEARestart;

                    if (([DateTime]::Now - $FailureTime).TotalSeconds -lt 180) {
                        $JeaRestartCounter += 1;
                    } else {
                        $JeaRestartCounter = 1;
                    }

                    $JeaPid = '';
                }

                Start-Sleep -Seconds 5;
                $JeaAliveCounter += 1;

                continue;
            }
            Start-Sleep -Seconds 100;
        }
    }
}
