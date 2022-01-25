<#
.SYNOPSIS
   Fetch the raw output values for a check command for each single object
   processed by New-IcingaCheck
.DESCRIPTION
   Fetch the raw output values for a check command for each single object
   processed by New-IcingaCheck
.FUNCTIONALITY
   Fetch the raw output values for a check command for each single object
   processed by New-IcingaCheck
.OUTPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Get-IcingaCheckSchedulerCheckData()
{
    return $global:Icinga.Private.Scheduler.CheckData;
}
