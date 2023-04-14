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
        $Service,
        [switch]$Force = $FALSE
    );

    if ($Global:Icinga.Protected.ServiceRestartLock -And $Force -eq $FALSE) {
        return;
    }

    $Result = Invoke-IcingaWindowsScheduledTask -JobType 'RestartWindowsService' -ObjectName $Service;

    if ($Result.Success -eq $FALSE) {
        Write-IcingaConsoleError $Result.ErrMsg;
    } else {
        Write-IcingaConsoleNotice $Result.Message;
    }

    if ($Service -eq 'icinga2') {
        $Global:Icinga.Protected.IcingaServiceState = $Result.Status;
    } elseif ($Service -eq 'icingapowershell') {
        $Global:Icinga.Protected.IfWServiceState = $Result.Status;
    }
}
