<#
.SYNOPSIS
   Fetches all available Performance Counter caregories on the system by using the
   registry and returns the entire content as array. Allows to filter for certain
   categories only
.DESCRIPTION
   Fetches all available Performance Counter caregories on the system by using the
   registry and returns the entire content as array. Allows to filter for certain
   categories only
.FUNCTIONALITY
   Fetches all available Performance Counter caregories on the system by using the
   registry and returns the entire content as array. Allows to filter for certain
   categories only
.EXAMPLE
   PS>Show-IcingaPerformanceCounterCategories;

   System
    Memory
    Browser
    Cache
    Process
    Thread
    PhysicalDisk
    ...
.EXAMPLE
   PS>Show-IcingaPerformanceCounterCategories -Filter 'Processor';

   Processor
.EXAMPLE
   PS>Show-IcingaPerformanceCounterCategories -Filter 'Processor', 'Memory';

   Memory
    Processor
.PARAMETER Filter
   A array of counter categories to filter for. Supports wildcard search
.INPUTS
   System.String
.OUTPUTS
   System.Array
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Show-IcingaPerformanceCounterCategories()
{
    param (
        [array]$Filter = @()
    );

    [array]$Counters          = @();
    [array]$FilteredCounters  = @();
    # Load our cache if it does exist yet
    $PerfCounterCache         = Get-IcingaPerformanceCounterCacheItem 'Icinga:CachedCounterList';

    # Create a cache for all available performance counter categories on the system
    if ($null -eq $PerfCounterCache -or $PerfCounterCache.Count -eq 0) {
        # Fetch the categories from the registry
        $PerfCounterCache = Get-ItemProperty `
            -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Perflib\009' `
            -Name 'counter' | Select-Object -ExpandProperty Counter;

        # Now lets loop our registry data and fetch only for counter categories
        # Ignore everything else and drop the information
        foreach ($counter in $PerfCounterCache) {
            # First filter out the ID's of the performance counter
            if (-Not ($counter -match "^[\d\.]+$") -And [string]::IsNullOrEmpty($counter) -eq $FALSE) {
                # Now check if the value we got is a counter category
                if ([System.Diagnostics.PerformanceCounterCategory]::Exists($counter) -eq $TRUE) {
                    $Counters += $counter;
                }
            }
        }

        # Set our cache to the current list of categories
        Add-IcingaPerformanceCounterCache -Counter 'Icinga:CachedCounterList' -Instances $Counters;
        $PerfCounterCache = $Counters;
    }

    # In case we have no filter applied, simply return the entire list
    if ($Filter.Count -eq 0) {
        return $PerfCounterCache;
    }

    # In case we do, check each counter category against our filter element
    foreach ($counter in $PerfCounterCache) {
        foreach ($element in $Filter) {
            if ($counter -like $element) {
                $FilteredCounters += $counter;
            }
        }
    }

    return $FilteredCounters;
}
