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
    param(
        $Service
    );

    if (Get-Service "$Service" -ErrorAction SilentlyContinue) {
        Write-IcingaConsoleNotice ([string]::Format('Restarting service "{0}"', $Service));
        powershell.exe -Command {
            $Service = $args[0]

            Restart-Service "$Service";
        } -Args $Service;
        
    } else {
        Write-IcingaConsoleWarning -Message 'The service "{0}" is not installed' -Objects $Service;
    }
}
