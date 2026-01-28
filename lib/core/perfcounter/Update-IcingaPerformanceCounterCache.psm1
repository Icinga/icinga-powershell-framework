<#
.SYNOPSIS
    Updates the cached instances of a specified performance counter in the Icinga PowerShell Framework.

.DESCRIPTION
    The Update-IcingaPerformanceCounterCache function synchronizes the cached instances of a given performance counter.
    It removes instances that no longer exist and adds new instances that are not yet cached.
    This ensures that the cache accurately reflects the current state of the performance counter instances.

.PARAMETER Counter
    The name of the performance counter whose cache should be updated.

.EXAMPLE
    Update-IcingaPerformanceCounterCache -Counter "\Processor(_Total)\% Processor Time"

    Updates the cache for the specified performance counter.

.NOTES
    This function is intended for internal use within the Icinga PowerShell Framework.
    It requires that the global cache variable and related functions are available.

#>
function Update-IcingaPerformanceCounterCache()
{
    param (
        $Counter
    );

    if ([string]::IsNullOrEmpty($Counter)) {
        return;
    }

    if ($Global:Icinga.Private.PerformanceCounter.Cache.ContainsKey($Counter) -eq $FALSE) {
        # If there is no cache entry for the provided counter, we don't need to do anything yet
        return;
    }

    # First we need to prepare some data by fetching the current instances of the counter
    # and the cached instances. We will then compare them and update the cache accordingly
    [array]$CounterInstances    = Show-IcingaPerformanceCounterInstances -Counter $Counter -NoNoticeOnMissingInstances;
    [array]$CachedInstances     = $Global:Icinga.Private.PerformanceCounter.Cache[$Counter];
    [array]$UpdatedInstances    = @();
    [array]$CachedInstanceNames = $CachedInstances.FullName;

    # We will now iterate over the cached instances and check if they are still present in the current
    # counter instances. If they are not, we will remove them from the cache.
    # If they are present, we will keep them in the updated instances array.
    for ($index = 0; $index -lt $CachedInstances.Count; $index++) {
        $cachedInstance = $CachedInstances[$index];
        $instanceName   = $cachedInstance.FullName;

        # If the instance is not in the current list, we remove it
        if ($CounterInstances.Value -contains $instanceName) {
            $UpdatedInstances += $cachedInstance;
        }
    }

    # Now we will iterate over the current counter instances and check if they are already cached.
    # If they are not, we will add them to the updated instances array.
    # This ensures that we only add new instances that are not already cached.
    for ($index = 0; $index -lt $CounterInstances.Count; $index++) {
        $instanceName = $CounterInstances[$index].Value;

        if ($CachedInstanceNames -notcontains $instanceName) {
            # If the instance is not cached, we create a new performance counter object
            # and add it to the updated instances array
            $UpdatedInstances += (New-IcingaPerformanceCounter -Counter $instanceName -SkipWait $TRUE -NoCache);
        }
    }

    # Finally, we update the cache with the new instances
    # This will ensure that the cache is up-to-date with the current state of the performance
    # counter instances
    $Global:Icinga.Private.PerformanceCounter.Cache[$Counter] = $UpdatedInstances;
}
