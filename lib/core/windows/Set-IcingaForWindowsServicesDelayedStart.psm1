<#
.SYNOPSIS
    Configures the Icinga services to use delayed auto-start.
.DESCRIPTION
    The `Set-IcingaForWindowsServicesDelayedStart` function sets the startup type of the Icinga 2 and Icinga PowerShell services to "delayed-auto" using the `sc.exe` command. This ensures that the services start after other critical system services during the boot process.
.EXAMPLE
    Set-IcingaForWindowsServicesDelayedStart

    This example sets the Icinga 2 and Icinga PowerShell services to delayed auto-start if they are present in the environment.
#>
function Set-IcingaForWindowsServicesDelayedStart()
{
    Set-IcingaServiceEnvironment;

    $IcingaAgentService      = $Global:Icinga.Protected.Environment.'Icinga Service';
    $IcingaForWindowsService = $Global:Icinga.Protected.Environment.'PowerShell Service';

    if ($null -ne $IcingaAgentService -And $IcingaAgentService.Present) {
        $ServiceUpdate = Start-IcingaProcess -Executable 'sc.exe' -Arguments 'config icinga2 start= delayed-auto';

        if ($ServiceUpdate.ExitCode -ne 0) {
            Write-IcingaConsoleError ([string]::Format('Failed to set the icinga2 service to delayed autostart: {0}', $ServiceUpdate.Message));
        } else {
            Write-IcingaConsoleNotice 'Successfully set the icinga2 service to delayed autostart';
        }
    }
    if ($null -ne $IcingaForWindowsService -And $IcingaForWindowsService.Present) {
        $ServiceUpdate = Start-IcingaProcess -Executable 'sc.exe' -Arguments 'config icingapowershell start= delayed-auto';

        if ($ServiceUpdate.ExitCode -ne 0) {
            Write-IcingaConsoleError ([string]::Format('Failed to set the icingapowershell service to delayed autostart: {0}', $ServiceUpdate.Message));
        } else {
            Write-IcingaConsoleNotice 'Successfully set the icingapowershell service to delayed autostart';
        }
    }
}
