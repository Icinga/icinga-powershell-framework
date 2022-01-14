<#
.SYNOPSIS
    Initialises the internal cache storage for Performance Counters
.DESCRIPTION
    Initialises the internal cache storage for Performance Counters
.FUNCTIONALITY
    Initialises the internal cache storage for Performance Counters
.EXAMPLE
    PS>New-IcingaPerformanceCounterCache;
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function New-IcingaPerformanceCounterCache()
{
    if ($null -eq $global:Icinga_PerfCounterCache) {
        $global:Icinga_PerfCounterCache = (
            [hashtable]::Synchronized(
                @{ }
            )
        );
    }
}
