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
    New-IcingaThreadInstance `
        -Name 'Main' `
        -ThreadPool (Get-IcingaThreadPool -Name 'MainPool') `
        -Command 'Add-IcingaServiceCheckDaemon' `
        -Start;
}
