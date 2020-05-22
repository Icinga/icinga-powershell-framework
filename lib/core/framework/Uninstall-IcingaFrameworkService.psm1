<#
.SYNOPSIS
    Uninstalls the Icinga PowerShell Service as a Windows Service
.DESCRIPTION
    Uninstalls the Icinga PowerShell Service as a Windows Service. The service binary
    will be left on the system.
.FUNCTIONALITY
    Uninstalls the Icinga PowerShell Service as a Windows Service
.EXAMPLE
    PS>Uninstall-IcingaFrameworkService;
.INPUTS
   System.String
.OUTPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

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
