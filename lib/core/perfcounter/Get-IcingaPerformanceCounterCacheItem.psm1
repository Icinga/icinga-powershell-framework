<#
.SYNOPSIS
   Fetches stored data for a given performance counter path. Returns
   $null if no values are assigned
.DESCRIPTION
   Fetches stored data for a given performance counter path. Returns
   $null if no values are assigned
.FUNCTIONALITY
   Fetches stored data for a given performance counter path. Returns
   $null if no values are assigned
.EXAMPLE
   PS>Get-IcingaPerformanceCounterCacheItem -Counter '\Processor(*)\% processor time';
.PARAMETER Counter
   The path to the counter to fetch data for
.INPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Get-IcingaPerformanceCounterCacheItem()
{
    param (
        $Counter
    );

    if ($global:Icinga_PerfCounterCache.ContainsKey($Counter)) {
        return $global:Icinga_PerfCounterCache[$Counter];
    }

    return $null;
}
