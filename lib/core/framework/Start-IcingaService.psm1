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
    param (
        $Service,
        [switch]$Force = $FALSE
    );

    if ($Global:Icinga.Protected.ServiceRestartLock -And $Force -eq $FALSE) {
        return;
    }

    $Result = Invoke-IcingaWindowsScheduledTask -JobType 'StartWindowsService' -ObjectName $Service;

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
