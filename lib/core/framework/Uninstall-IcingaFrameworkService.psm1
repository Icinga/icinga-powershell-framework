function Uninstall-IcingaFrameworkService()
{
    Stop-IcingaService 'icingapowershell';
    Start-Sleep -Seconds 1;

    $ServiceCreation = Start-IcingaProcess -Executable 'sc.exe' -Arguments 'delete icingapowershell';

    switch ($ServiceCreation.ExitCode) {
        0 {
            Write-IcingaConsoleNotice 'Icinga PowerShell Service was successfully removed';
        }
        1060 {
            Write-IcingaConsoleWarning 'The Icinga PowerShell Service is not installed';
        }
        Default {
            throw ([string]::Format('Failed to install Icinga PowerShell Service: {0}{1}', $ServiceCreation.Message, $ServiceCreation.Error));
        }
    }
}
