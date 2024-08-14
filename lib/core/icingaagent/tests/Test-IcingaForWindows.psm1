function Test-IcingaForWindows()
{
    param (
        [switch]$ResolveProblems = $FALSE
    );

    Write-IcingaConsoleNotice 'Collecting Icinga for Windows environment information';
    Set-IcingaServiceEnvironment -Force;

    $IcingaAgentData    = Get-IcingaAgentInstallation;
    $IcingaService      = $Global:Icinga.Protected.Environment.'Icinga Service';
    $IfWService         = $Global:Icinga.Protected.Environment.'PowerShell Service';

    if ($IcingaService.Present -eq $FALSE -And $IfWService.Present -eq $FALSE -And $IcingaAgentData.Installed -eq $FALSE) {
        Write-IcingaConsoleNotice 'The Icinga Agent and Icinga for Windows service are not installed and the Icinga Agent is not present on the system';
        return;
    };

    if ($IcingaAgentData.Installed -And $IcingaService.Present -eq $FALSE) {
        if ($ResolveProblems -eq $FALSE) {
            Write-IcingaTestOutput -Severity Failed -Message 'The Icinga Agent service is not installed, while Icinga Agent itself is present on the system.';
        } else {
            Write-IcingaConsoleNotice 'Fixing problems with Icinga Service not present for installed Icinga Agent';
            Repair-IcingaService -RootFolder $IcingaAgentData.RootDir;
        }
    } elseif ($IcingaAgentData.Installed -eq $FALSE -And $IcingaService.Present) {
        Write-IcingaTestOutput -Severity Failed -Message 'The Icinga Agent service is installed, while Icinga Agent itself is not present on the system.';
    } elseif ($IcingaService.Present -eq $FALSE) {
        Write-IcingaTestOutput -Severity Warning -Message 'The Icinga Agent service seems not to be installed';
    } else {
        Write-IcingaTestOutput -Severity Passed -Message 'The Icinga Agent service and the Icinga Agent are installed on the system';
    }

    if ($IfWService.Present -eq $FALSE) {
        Write-IcingaTestOutput -Severity Warning -Message 'The Icinga for Windows service seems not to be installed';
    } else {
        Write-IcingaTestOutput -Severity Passed -Message 'The Icinga for Windows service is installed on the system';

        if ([string]::IsNullOrEmpty($IfWService.ServicePath) -eq $FALSE) {
            $IfWServicePath = $IfWService.ServicePath.Substring(1, $IfWService.ServicePath.IndexOf('" ') - 1);
            if (Test-Path $IfWServicePath) {
                Write-IcingaTestOutput -Severity Passed -Message ([string]::Format('The Icinga for Windows service binary does exist: "{0}"', $IfWServicePath));
            } else {
                Write-IcingaTestOutput -Severity Failed -Message ([string]::Format('The Icinga for Windows service binary could not be found: "{0}"', $IfWServicePath));
            }
        } else {
            Write-IcingaTestOutput -Severity Failed -Message 'The Icinga for Windows service path seems to be not configured';
        }
    }

    Test-IcingaForWindowsService -ResolveProblems:$ResolveProblems | Out-Null;

    if ($IcingaService.Present -And $IfWService.Present -And $IfWService.User.ToLower() -ne $IcingaService.User.ToLower()) {
        Write-IcingaTestOutput -Severity Warning -Message (
            [string]::Format(
                'The Icinga Agent service user "{0}" is not matching the Icinga for Windows service user "{1}"',
                $IcingaService.User,
                $IfWService.User
            )
        );
    } else {
        Write-IcingaTestOutput -Severity Passed -Message (
            [string]::Format(
                'The Icinga Agent service user "{0}" is matching the Icinga for Windows service user "{1}"',
                $IcingaService.User,
                $IfWService.User
            )
        );
    }

    if ((Test-IcingaAgentServicePermission) -eq $FALSE -And $ResolveProblems) {
        Write-IcingaConsoleNotice 'Fixing problems with Icinga service user permissions';
        Set-IcingaAgentServicePermission;
    }

    [array]$TestingDirectory = @(
        (Join-Path -Path $Env:ProgramData -ChildPath '\icinga2\etc'),
        (Join-Path -Path $Env:ProgramData -ChildPath '\icinga2\var'),
        (Get-IcingaCacheDir),
        (Get-IcingaPowerShellConfigDir),
        (Join-Path -Path (Get-IcingaFrameworkRootPath) -ChildPath 'certificate')
    );

    foreach ($entry in $TestingDirectory) {
        if ((Test-IcingaAcl -Directory $entry -WriteOutput) -eq $FALSE -And $ResolveProblems) {
            Write-IcingaConsoleNotice 'Fixing permission problem for Directory {0}' -Objects $entry;
            Set-IcingaAcl -Directory $entry;
        }
    }

    if ((Test-IcingaStateFile -WriteOutput) -eq $FALSE -And $ResolveProblems) {
        Write-IcingaConsoleNotice 'Fixing problems with Icinga State file';
        Repair-IcingaStateFile;
    }

    if ($IcingaAgentData.Installed) {
        Test-IcingaAgentConfig | Out-Null;
        if (Test-IcingaAgentFeatureEnabled -Feature 'debuglog') {
            Write-IcingaTestOutput -Severity 'Warning' -Message 'The debug log of the Icinga Agent is enabled. Please keep in mind to disable it once testing is done, as a huge amount of data is generated'
        } else {
            Write-IcingaTestOutput -Severity 'Passed' -Message 'Icinga Agent debug log is disabled'
        }
    }

    [hashtable]$DaemonList = Get-IcingaBackgroundDaemons;

    if ($DaemonList.ContainsKey('Start-IcingaWindowsRESTApi') -eq $FALSE) {
        if ($ResolveProblems -eq $FALSE) {
            Write-IcingaTestOutput -Severity Failed -Message 'The Icinga for Windows REST-Api is not configured to start with the daemon';
        } else {
            Write-IcingaConsoleNotice 'Fixing problems with missing Icinga for Windows REST-Api configuration';
            Register-IcingaBackgroundDaemon -Command 'Start-IcingaWindowsRESTApi';
            Add-IcingaRESTApiCommand -Command 'Invoke-IcingaCheck*' -Endpoint 'apichecks';
        }
    } else {
        Write-IcingaTestOutput -Severity Passed -Message 'The Icinga for Windows REST-Api is configured to start with the daemon';
    }

    if ((Get-IcingaFrameworkApiChecks) -eq $FALSE) {
        if ($ResolveProblems -eq $FALSE) {
            Write-IcingaTestOutput -Severity Failed -Message 'The Icinga for Windows REST-Api is not configured to allow API checks';
        } else {
            Write-IcingaConsoleNotice 'Fixing problems with missing Icinga for Windows API-Checks feature configuration';
            Enable-IcingaFrameworkApiChecks;
        }
    } else {
        Write-IcingaTestOutput -Severity Passed -Message 'The Icinga for Windows REST-Api is configured to allow API checks';
    }

    $IfWCertificate = Get-IcingaForWindowsCertificate;
    $Hostname       = Get-IcingaHostname -ReadConstants;

    if ($null -eq $IfWCertificate) {
        if ($ResolveProblems -eq $FALSE) {
            Write-IcingaTestOutput -Severity Failed -Message 'The Icinga for Windows certificate is not installed on the system';
        } else {
            Write-IcingaConsoleNotice 'Fixing problems with missing Icinga for Windows certificate';
            Start-IcingaWindowsScheduledTaskRenewCertificate;
            $IfWCertificate = Get-IcingaForWindowsCertificate;
        }
    }

    if ($null -ne $IfWCertificate) {
        if ($IfWCertificate.Issuer.ToLower() -eq ([string]::Format('cn={0}', $Hostname).ToLower())) {
            Write-IcingaTestOutput -Severity Failed -Message 'The Icinga for Windows certificate seems to be not signed by our Icinga CA yet. Re-Creating the certificate might resolve this issue [IWKB000013]';
            if ($ResolveProblems) {
                Write-IcingaConsoleNotice 'Fixing problems with missing not signed Icinga for Windows certificate by re-creating it from the Icinga Agent certificate';
                Start-IcingaWindowsScheduledTaskRenewCertificate;
                Start-Sleep -Seconds 5;
                $IfWCertificate = Get-IcingaForWindowsCertificate;

                if ($IfWCertificate.Issuer.ToLower() -eq ([string]::Format('cn={0}', $Hostname).ToLower())) {
                    Write-IcingaTestOutput -Severity Passed -Message 'The Icinga for Windows certificate is still not properly signed. Please have a look on your Icinga Agent side and validate the configuration is correct and the certificate request was processed [IWKB000013]';
                } else {
                    Write-IcingaTestOutput -Severity Passed -Message 'The Icinga for Windows certificate is installed on the system and possibly signed by a valid CA';
                }
            }
        } else {
            Write-IcingaTestOutput -Severity Passed -Message 'The Icinga for Windows certificate is installed on the system and possibly signed by a valid CA';
        }
    }

    $JEAContext     = Get-IcingaJEAContext;
    $JEASessionFile = Get-IcingaJEASessionFile;
    $ServicePid     = Get-IcingaForWindowsServicePid;
    $JEAServicePid  = Get-IcingaJEAServicePid;

    if ([string]::IsNullOrEmpty($JEAContext)) {
        Write-IcingaTestOutput -Severity Warning -Message 'Icinga for Windows is configured without a JEA-Profile. It is highly recommended to use JEA for advanced security and easier permission handling';
    } else {
        Write-IcingaTestOutput -Severity Passed -Message 'Icinga for Windows is configured with a JEA-Profile';
    }

    if ($IfWService.Status -eq 'Running') {
        if ([string]::IsNullOrEmpty($JEAContext) -eq $FALSE -And [string]::IsNullOrEmpty($JEAServicePid)) {
            if ($ResolveProblems -eq $FALSE) {
                Write-IcingaTestOutput -Severity Failed -Message 'The Icinga for Windows service is running, but the JEA-Session is not working. Please validate the proper installation of JEA and try to rebuild the security profile.';
            } else {
                Write-IcingaConsoleNotice 'Fixing problems with JEA session by updating the Icinga for Windows JEA-Profile';
                Update-IcingaJeaProfile -RebuildFramework;
            }
        } elseif ([string]::IsNullOrEmpty($JEAContext) -And [string]::IsNullOrEmpty($JEAServicePid)) {
            Write-IcingaTestOutput -Severity Passed -Message 'The Icinga for Windows service is running';
        } else {
            Write-IcingaTestOutput -Severity Passed -Message 'The Icinga for Windows service is running and the JEA-Service is running as well';
        }
    } else {
        Write-IcingaTestOutput -Severity Failed -Message 'The Icinga for Windows service is currently not running';
    }

    Set-IcingaTLSVersion;

    try {
        $ApiResult = Invoke-IcingaForWindowsRESTApi;
        Write-IcingaTestOutput -Severity Passed -Message 'The Icinga for Windows REST-Api responded successfully on this machine';
    } catch {
        if ($IfWService.User.ToLower() -eq 'nt authority\networkservice') {
            Write-IcingaTestOutput -Severity Failed -Message ([string]::Format('The Icinga for Windows REST-Api responded with an error on this machine, which is expected when using the default NetworkService account [IWKB000018]: "{0}"', $_.Exception.Message));
        } else {
            if ($ResolveProblems -eq $FALSE) {
                Write-IcingaTestOutput -Severity Failed -Message ([string]::Format('The Icinga for Windows REST-Api responded with an error on this machine: "{0}"', $_.Exception.Message));
            } else {
                Write-IcingaConsoleNotice 'Fixing problems with Icinga for Windows REST-Api by restarting the Icinga for Windows service';
                Restart-IcingaForWindows;
            }
        }
    }
}
