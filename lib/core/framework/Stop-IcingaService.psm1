<#
.SYNOPSIS
    Wrapper for Stop-Service which catches errors and prints proper output messages
.DESCRIPTION
    Stops a service if it is installed and prints console messages if a stop
    was triggered or the service is not installed
.FUNCTIONALITY
    Wrapper for Stop-Service which catches errors and prints proper output messages
.EXAMPLE
    PS>Stop-IcingaService -Service 'icinga2';
.PARAMETER Service
    The name of the service to be stopped
.INPUTS
   System.String
.OUTPUTS
   Null
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Stop-IcingaService()
{
    param(
        $Service
    );

    if (Get-Service $Service -ErrorAction SilentlyContinue) {
        Write-IcingaConsoleNotice -Message 'Stopping service "{0}"' -Objects $Service;

        Invoke-IcingaCommand -ArgumentList $Service -ScriptBlock {
            try {
                Stop-Service "$($IcingaShellArgs[0])" -ErrorAction Stop;
                Start-Sleep -Seconds 2;
                Optimize-IcingaForWindowsMemory;
            } catch {
                Write-IcingaConsoleError -Message 'Failed to stop service "{0}". Error: {1}' -Objects $IcingaShellArgs[0], $_.Exception.Message;
            }
        } | Out-Null;
    } else {
        Write-IcingaConsoleWarning -Message 'The service "{0}" is not installed' -Objects $Service;
    }

    Optimize-IcingaForWindowsMemory;
}
