function Invoke-IcingaForWindowsMigration()
{
    $IcingaForWindowsService = Get-IcingaForWindowsServiceData;

    if (([string]::IsNullOrEmpty($IcingaForWindowsService.FullPath) -eq $FALSE -And (Test-Path $IcingaForWindowsService.FullPath))) {
        $ServiceBinaryData = Read-IcingaServicePackage -File $IcingaForWindowsService.FullPath;

        if ($ServiceBinaryData.FileVersion -lt (New-IcingaVersionObject -Version '1.2.0')) {
            Write-IcingaConsoleWarning -Message 'You are running a Icinga for Windows Service binary older than v1.2.0. You need to upgrade to v1.2.0 or later before you can use Icinga for Windows properly. You can update it with "Update-Icinga -Name service"';
            return;
        }
    }

    # Upgrade to v1.8.0
    if (Test-IcingaForWindowsMigration -MigrationVersion (New-IcingaVersionObject -Version '1.8.0')) {
        $ServiceStatus = (Get-Service 'icingapowershell' -ErrorAction SilentlyContinue).Status;

        Write-IcingaConsoleNotice 'Applying pending migrations required for Icinga for Windows v1.8.0';
        if ($ServiceStatus -eq 'Running') {
            Stop-IcingaForWindows;
        }

        $ApiChecks = Get-IcingaPowerShellConfig -Path 'Framework.Experimental.UseApiChecks';

        if ($null -ne $ApiChecks) {
            Remove-IcingaPowerShellConfig -Path 'Framework.Experimental.UseApiChecks' | Out-Null;
            Set-IcingaPowerShellConfig -Path 'Framework.ApiChecks' -Value $ApiChecks;
        }

        # Remove all prior EventLog handler
        Unregister-IcingaEventLog;
        # Add new Icinga for Windows EventLog
        Register-IcingaEventLog;

        Set-IcingaForWindowsMigration -MigrationVersion (New-IcingaVersionObject -Version '1.8.0');

        # For upgrading to v1.8.0 it is required to restart the Icinga for Windows service
        if ($ServiceStatus -eq 'Running') {
            Restart-IcingaService -Service 'icingapowershell';
        }
    }

    if (Test-IcingaForWindowsMigration -MigrationVersion (New-IcingaVersionObject -Version '1.10.0')) {
        Write-IcingaConsoleNotice 'Applying pending migrations required for Icinga for Windows v1.10.0';

        $ServiceStatus = (Get-Service 'icingapowershell' -ErrorAction SilentlyContinue).Status;

        if ($ServiceStatus -eq 'Running') {
            Stop-IcingaForWindows;
        }

        # Convert the time intervals for the background daemon services from the previous index handling
        # 1, 3, 5, 15 as example to 1m, 3m, 5m, 15m
        $BackgroundServices = Get-IcingaPowerShellConfig -Path 'BackgroundDaemon.RegisteredServices';

        # Only run this migration in case background services are defined
        if ($null -ne $BackgroundServices) {
            foreach ($service in $BackgroundServices.PSObject.Properties) {
                [array]$ConvertedTimeIndex = @();

                foreach ($interval in $service.Value.TimeIndexes) {
                    if (Test-Numeric $interval) {
                        $ConvertedTimeIndex += [string]::Format('{0}m', $interval);
                    } else {
                        $ConvertedTimeIndex = $interval;
                    }
                }

                $service.Value.TimeIndexes = $ConvertedTimeIndex;
            }

            Set-IcingaPowerShellConfig -Path 'BackgroundDaemon.RegisteredServices' -Value $BackgroundServices;
        }

        Set-IcingaForWindowsMigration -MigrationVersion (New-IcingaVersionObject -Version '1.10.0');

        if ($ServiceStatus -eq 'Running') {
            Restart-IcingaForWindows;
        }
    }

    if (Test-IcingaForWindowsMigration -MigrationVersion (New-IcingaVersionObject -Version '1.10.1')) {
        Write-IcingaConsoleNotice 'Applying pending migrations required for Icinga for Windows v1.10.1';

        # Fix Icinga for Windows v1.10.0 broken background service registration
        if ($null -eq (Get-IcingaPowerShellConfig -Path 'BackgroundDaemon.RegisteredServices')) {
            Remove-IcingaPowerShellConfig -Path 'BackgroundDaemon.RegisteredServices';
        }

        Set-IcingaForWindowsMigration -MigrationVersion (New-IcingaVersionObject -Version '1.10.1');
    }

    if (Test-IcingaForWindowsMigration -MigrationVersion (New-IcingaVersionObject -Version '1.12.0')) {
        Write-IcingaConsoleNotice 'Applying pending migrations required for Icinga for Windows v1.12.0';

        # Add a new scheduled task to automatically renew the Icinga for Windows certificate
        Register-IcingaWindowsScheduledTaskRenewCertificate -Force;
        # Start the task to ensure the certificate is generated
        Start-IcingaWindowsScheduledTaskRenewCertificate;

        Set-IcingaForWindowsMigration -MigrationVersion (New-IcingaVersionObject -Version '1.12.0');
    }

    if (Test-IcingaForWindowsMigration -MigrationVersion (New-IcingaVersionObject -Version '1.12.1')) {
        Write-IcingaConsoleNotice 'Applying pending migrations required for Icinga for Windows v1.12.1';

        # Fixes the size of the Icinga for Windows Eventlog, allowing more logs to be collected
        # before older ones are faded out
        Register-IcingaEventLog;

        # Fixes user environment which is now set to LocalSystem, allowing configurations over WinRM and SSH
        Register-IcingaWindowsScheduledTaskRenewCertificate -Force;

        Set-IcingaForWindowsMigration -MigrationVersion (New-IcingaVersionObject -Version '1.12.1');
    }

    if (Test-IcingaForWindowsMigration -MigrationVersion (New-IcingaVersionObject -Version '1.12.2')) {
        Write-IcingaConsoleNotice 'Applying pending migrations required for Icinga for Windows v1.12.2';

        # Revokes certificate handling to run as local Administrators group with highest privileges instead of LocalSystem
        Register-IcingaWindowsScheduledTaskRenewCertificate -Force;
        Start-Sleep -Seconds 1;
        # Enforce the certificate creation to update broken certificates
        Start-IcingaWindowsScheduledTaskRenewCertificate;
        # Restart the Icinga for Windows service
        Start-Sleep -Seconds 2;
        Restart-IcingaForWindows;

        Set-IcingaForWindowsMigration -MigrationVersion (New-IcingaVersionObject -Version '1.12.2');
    }

    if (Test-IcingaForWindowsMigration -MigrationVersion (New-IcingaVersionObject -Version '1.12.3')) {
        Write-IcingaConsoleNotice 'Applying pending migrations required for Icinga for Windows v1.12.3';

        # Updates certificate renew task to properly handle changes in the certificate renewal process
        Register-IcingaWindowsScheduledTaskRenewCertificate -Force;
        Start-Sleep -Seconds 1;
        # Enforce the certificate creation to update broken certificates
        Start-IcingaWindowsScheduledTaskRenewCertificate;
        # Restart the Icinga for Windows service
        Start-Sleep -Seconds 2;
        Restart-IcingaForWindows;

        Set-IcingaForWindowsMigration -MigrationVersion (New-IcingaVersionObject -Version '1.12.3');
    }

    if (Test-IcingaForWindowsMigration -MigrationVersion (New-IcingaVersionObject -Version '1.13.0')) {
        Write-IcingaConsoleNotice 'Applying pending migrations required for Icinga for Windows v1.13.0';

        # Updates certificate renew task to handle changes made which now stores the Icinga CA inside the cert store
        Start-IcingaWindowsScheduledTaskRenewCertificate;
        # Ensure the Icinga Agent is not spamming the Application log by default
        Write-IcingaAgentEventLogConfig -Severity 'warning';
        # Set our newly added process update task
        Register-IcingaWindowsScheduledTaskProcessPriority -Force;

        Set-IcingaForWindowsMigration -MigrationVersion (New-IcingaVersionObject -Version '1.13.0');
    }

    if (Test-IcingaForWindowsMigration -MigrationVersion (New-IcingaVersionObject -Version '1.13.0.1')) {
        Write-IcingaConsoleNotice 'Applying pending migrations required for Icinga for Windows v1.13.0.1';

        # Set our newly added process update task
        Register-IcingaWindowsScheduledTaskProcessPriority -Force;

        Set-IcingaForWindowsMigration -MigrationVersion (New-IcingaVersionObject -Version '1.13.0.1');
    }
}
