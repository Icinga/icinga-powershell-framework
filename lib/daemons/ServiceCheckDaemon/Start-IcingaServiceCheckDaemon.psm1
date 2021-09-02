<#
.SYNOPSIS
   A background daemon executing registered service checks in the background to fetch
   metrics for certain checks over time. Time frames are configurable individual
.DESCRIPTION
   This background daemon will execute checks registered with "Register-IcingaServiceCheck"
   for the given time interval and store the collected metrics for a defined period of time
   inside a JSON file. Check values collected by this daemon are then automatically added
   to regular check executions for additional performance metrics.

   Example: Register-IcingaServiceCheck -CheckCommand 'Invoke-IcingaCheckCPU' -Interval 30 -TimeIndexes 1,3,5,15;

   This will execute the CPU check every 30 seconds and calculate the average of 1, 3, 5 and 15 minutes

   More Information on
   https://icinga.com/docs/icinga-for-windows/latest/doc/service/02-Register-Daemons/
   https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function Start-IcingaServiceCheckDaemon()
{
    New-IcingaThreadInstance -Name "Icinga_PowerShell_ServiceCheck_Scheduler" -ThreadPool $IcingaDaemonData.IcingaThreadPool.BackgroundPool -Command 'Add-IcingaServiceCheckDaemon' -CmdParameters @{ 'IcingaDaemonData' =  $global:IcingaDaemonData } -Start;
}

function Add-IcingaServiceCheckDaemon()
{
    param (
        $IcingaDaemonData
    );

    Use-Icinga -LibOnly -Daemon;

    $IcingaDaemonData.IcingaThreadPool.Add('ServiceCheckPool', (New-IcingaThreadPool -MaxInstances (Get-IcingaConfigTreeCount -Path 'BackgroundDaemon.RegisteredServices')));

    while ($TRUE) {

        $RegisteredServices = Get-IcingaRegisteredServiceChecks;

        foreach ($service in $RegisteredServices.Keys) {
            [string]$ThreadName = [string]::Format('Icinga_Background_Service_Check_{0}', $service);
            if ((Test-IcingaThread $ThreadName)) {
                continue;
            }

            [hashtable]$ServiceArgs = @{ };

            if ($null -ne $RegisteredServices[$service].Arguments) {
                foreach ($property in $RegisteredServices[$service].Arguments.PSObject.Properties) {
                    if ($ServiceArgs.ContainsKey($property.Name)) {
                        continue;
                    }

                    $ServiceArgs.Add($property.Name, $property.Value)
                }
            }

            Start-IcingaServiceCheckTask -CheckId $service -CheckCommand $RegisteredServices[$service].CheckCommand -Arguments $ServiceArgs -Interval $RegisteredServices[$service].Interval -TimeIndexes $RegisteredServices[$service].TimeIndexes;
        }
        Start-Sleep -Seconds 1;
    }
}

function Start-IcingaServiceCheckTask()
{
    param(
        $CheckId,
        $CheckCommand,
        $Arguments,
        $Interval,
        $TimeIndexes
    );

    [string]$ThreadName = [string]::Format('Icinga_Background_Service_Check_{0}', $CheckId);

    New-IcingaThreadInstance -Name $ThreadName -ThreadPool $IcingaDaemonData.IcingaThreadPool.ServiceCheckPool -Command 'Add-IcingaServiceCheckTask' -CmdParameters @{
        'IcingaDaemonData' = $global:IcingaDaemonData;
        'CheckCommand'     = $CheckCommand;
        'Arguments'        = $Arguments;
        'Interval'         = $Interval;
        'TimeIndexes'      = $TimeIndexes
        'CheckId'          = $CheckId;
    } -Start;
}
