<#
.SYNOPSIS
   Create a new environment in which we can store check results, performance data
   and values over time or executed plugins.

   Usage:

   Access the string plugin output by calling `Get-IcingaCheckSchedulerPluginOutput`
   Access possible performance data with `Get-IcingaCheckSchedulerPerfData`

   If you execute check plugins, ensure you read both of these functions to fetch the
   result of the plugin call and to clear the stack and memory of the check data.

   If you do not require the output, you can write them to Null

   Get-IcingaCheckSchedulerPluginOutput | Out-Null;
   Get-IcingaCheckSchedulerPerfData | Out-Null;

   IMPORTANT:
   In addition each value for each object created with `New-IcingaCheck` is stored
   with a timestamp for the check command inside a hashtable. If you do not require
   these data, you MUST call `Clear-IcingaCheckSchedulerCheckData` to free memory
   and clear data from the stack!

   If you are finished with all data processing and do not require anything within
   memory anyway, you can safely call `Clear-IcingaCheckSchedulerEnvironment` to
   do the same thing in one call.
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

function New-IcingaCheckSchedulerEnvironment()
{
    # Legacy code
    if ($IcingaDaemonData.IcingaThreadContent.ContainsKey('Scheduler') -eq $FALSE) {
        $IcingaDaemonData.IcingaThreadContent.Add('Scheduler', @{ });
    }

    if ($null -eq $global:Icinga) {
        $global:Icinga = @{ };
    }

    if ($global:Icinga.ContainsKey('CheckResults') -eq $FALSE) {
        $global:Icinga.Add('CheckResults', @());
    }
    if ($global:Icinga.ContainsKey('PerfData') -eq $FALSE) {
        $global:Icinga.Add('PerfData', @());
    }
    if ($global:Icinga.ContainsKey('CheckData') -eq $FALSE) {
        $global:Icinga.Add('CheckData', @{ });
    }
}
