<#
.SYNOPSIS
    Prints a list of all available Performance Counters for a specified category
.DESCRIPTION
    Prints a list of all available Performance Counters for a specified category
.FUNCTIONALITY
    Prints a list of all available Performance Counters for a specified category
.EXAMPLE
    PS>Show-IcingaPerformanceCounters -CounterCategory 'Processor';

    \Processor(*)\dpcs queued/sec
    \Processor(*)\% c1 time
    \Processor(*)\% idle time
    \Processor(*)\c3 transitions/sec
    \Processor(*)\% c2 time
    \Processor(*)\% dpc time
    \Processor(*)\% privileged time
.PARAMETER CounterCategory
    The name of the category to fetch availble counters for
.INPUTS
    System.String
.OUTPUTS
    System.Array
.LINK
    https://github.com/Icinga/icinga-powershell-framework
#>
function Show-IcingaPerformanceCounters()
{
    param (
        [string]$CounterCategory
    );

    [hashtable]$counters = @{};

    if ([string]::IsNullOrEmpty($CounterCategory)) {
        $counters.Add('error', 'Please specify a counter category');
        return $counters;
    }

    try {
        # At first create our Performance Counter object for the category we specified
        $Category = New-Object System.Diagnostics.PerformanceCounterCategory($CounterCategory);

        # Now loop  through all keys to find the name of available counters
        foreach ($counter in $Category.ReadCategory().Keys) {
            [string]$CounterInstanceAddition = '';

            # As counters might also have instances (like interfaces, disks, paging file), we should
            # try to load them as well
            foreach ($instance in $Category.ReadCategory()[$counter].Keys) {
                # If we do not match this magic string, we have multiple instances we can access
                # to get informations for different disks, volumes and interfaces for example
                if ($instance -ne 'systemdiagnosticsperfcounterlibsingleinstance') {
                    # Re-Write the name we return of the counter to something we can use directly
                    # within our modules to load data from. A returned counter will look like this
                    # for example:
                    # \PhysicalDisk(*)\avg. disk bytes/read
                    [string]$UsableCounterName = [string]::Format('\{0}(*)\{1}', $CounterCategory, $counter);
                    if ($counters.ContainsKey($UsableCounterName) -eq $TRUE) {
                        $counters[$UsableCounterName] += $Category.ReadCategory()[$counter][$instance];
                    } else {
                        $counters.Add($UsableCounterName, @( $Category.ReadCategory()[$counter][$instance] ));
                    }
                } else {
                    # For counters with no instances, we still require to return a re-build Performance Counter
                    # output, to make later usage in our modules very easy. This can look like this:
                    # \System\system up time
                    [string]$UsableCounterName = [string]::Format('\{0}\{1}', $CounterCategory, $counter);
                    $counters.Add($UsableCounterName, $null);
                }
            }
        };
    } catch {
        # In case we run into an error, return an error message
        $counters.Add('error', $_.Exception.Message);
    }

    return $counters.Keys;
}
