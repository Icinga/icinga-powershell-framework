function Invoke-IcingaForWindowsMigration()
{
    # Upgrade to v1.8.0
    if (Test-IcingaForWindowsMigration -MigrationVersion (New-IcingaVersionObject -Version '1.8.0')) {
        $ServiceStatus = (Get-Service 'icingapowershell' -ErrorAction SilentlyContinue).Status;

        Write-IcingaConsoleNotice 'Applying pending migrations required for Icinga for Windows v1.8.0';
        if ($ServiceStatus -eq 'Running') {
            Stop-IcingaWindowsService;
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
}
