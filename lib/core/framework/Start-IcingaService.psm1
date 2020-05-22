<#
.SYNOPSIS
    Wrapper for Start-Service which catches errors and prints proper output messages
.DESCRIPTION
    Starts a service if it is installed and prints console messages if a start
    was triggered or the service is not installed
.FUNCTIONALITY
    Wrapper for Start-Service which catches errors and prints proper output messages
.EXAMPLE
    PS>Start-IcingaService -Service 'icinga2';
.PARAMETER Service
    The name of the service to be started
.INPUTS
   System.String
.OUTPUTS
   Null
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Start-IcingaService()
{
    param(
        $Service
    );

    if (Get-Service $Service -ErrorAction SilentlyContinue) {
        Write-IcingaConsoleNotice -Message 'Starting service "{0}"' -Objects $Service;
        Start-Service $Service;
    } else {
        Write-IcingaConsoleWarning -Message 'The service "{0}" is not installed' -Objects $Service;
    }
}
