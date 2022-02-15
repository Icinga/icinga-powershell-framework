<#
.SYNOPSIS
    Wrapper for Restart-Service which catches errors and prints proper output messages
.DESCRIPTION
    Restarts a service if it is installed and prints console messages if a restart
    was triggered or the service is not installed
.FUNCTIONALITY
    Wrapper for restart service which catches errors and prints proper output messages
.EXAMPLE
    PS>Restart-IcingaService -Service 'icinga2';
.PARAMETER Service
    The name of the service to be restarted
.INPUTS
   System.String
.OUTPUTS
   Null
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Restart-IcingaService()
{
    param (
        $Service
    );

    if (Get-Service "$Service" -ErrorAction SilentlyContinue) {
        Write-IcingaConsoleNotice ([string]::Format('Restarting service "{0}"', $Service));

        Invoke-IcingaCommand -ArgumentList $Service -ScriptBlock {
            try {
                Restart-Service "$($IcingaShellArgs[0])" -ErrorAction Stop;
                Start-Sleep -Seconds 2;
                Optimize-IcingaForWindowsMemory;
            } catch {
                Write-IcingaConsoleError -Message 'Failed to restart service "{0}". Error: {1}' -Objects $IcingaShellArgs[0], $_.Exception.Message;
            }
        }
    } else {
        Write-IcingaConsoleWarning -Message 'The service "{0}" is not installed' -Objects $Service;
    }

    Optimize-IcingaForWindowsMemory;
}
