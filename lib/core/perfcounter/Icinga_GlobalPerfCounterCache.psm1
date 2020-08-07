function New-IcingaPerformanceCounterCache()
{
    if ($null -eq $global:Icinga_PerfCounterCache) {
        $global:Icinga_PerfCounterCache = (
            [hashtable]::Synchronized(
                @{}
            )
        );
    }
}

function Add-IcingaPerformanceCounterCache()
{
    param (
        $Counter,
        $Instances
    );

    if ($global:Icinga_PerfCounterCache.ContainsKey($Counter)) {
        $global:Icinga_PerfCounterCache[$Counter] = $Instances;
    } else {
        $global:Icinga_PerfCounterCache.Add(
            $Counter, $Instances
        );
    }
}

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
