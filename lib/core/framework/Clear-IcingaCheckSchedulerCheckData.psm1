<#
.SYNOPSIS
   Clear all cached values for all check commands executed by this thread.
   This is mandatory as we might run into a memory leak otherwise!
.DESCRIPTION
   Clear all cached values for all check commands executed by this thread.
   This is mandatory as we might run into a memory leak otherwise!
.FUNCTIONALITY
   Clear all cached values for all check commands executed by this thread.
   This is mandatory as we might run into a memory leak otherwise!
.OUTPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Clear-IcingaCheckSchedulerCheckData()
{
    $global:Icinga.Private.Scheduler.CheckData.Clear();
}
