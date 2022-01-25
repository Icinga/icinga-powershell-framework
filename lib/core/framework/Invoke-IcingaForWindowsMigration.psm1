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
