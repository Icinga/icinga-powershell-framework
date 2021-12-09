<#
.SYNOPSIS
    Accepts a list of Performance Counters which will all be fetched at once and
    returned as a hashtable object. No additional configuration is required.
.DESCRIPTION
    Accepts a list of Performance Counters which will all be fetched at once and
    returned as a hashtable object. No additional configuration is required.
.FUNCTIONALITY
    Accepts a list of Performance Counters which will all be fetched at once and
    returned as a hashtable object. No additional configuration is required.
.EXAMPLE
    PS>New-IcingaPerformanceCounterArray -CounterArray '\Processor(*)\% processor time', '\Memory\committed bytes';

    Name                           Value
    ----                           -----
    \Processor(*)\% processor time {\Processor(7)\% processor time, \Processor(6)\% processor time, \Processor(0)\% proc...
    \Memory\committed bytes        {error, sample, type, value...}
.PARAMETER CounterArray
    An array of Performance Counters which will all be fetched at once
.INPUTS
    System.String
.OUTPUTS
    System.Hashtable
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function New-IcingaPerformanceCounterArray()
{
    param(
        [array]$CounterArray = @()
    )

    [hashtable]$CounterResult = @{ };
    [bool]$RequireSleep       = $TRUE;
    foreach ($counter in $CounterArray) {
        # We want to speed up things with loading, so we will check if a specified
        # Counter is already cached within our hashtable. If it is not, we sleep
        # at the end of the function the required 500ms and don't have to wait
        # NumOfCounters * 500 milliseconds for the first runs. This will speed
        # up the general loading of counters and will not require some fancy
        # pre-caching / configuration handler
        $CachedCounter = Get-IcingaPerformanceCounterCacheItem -Counter $Counter;

        if ($null -ne $CachedCounter) {
            $RequireSleep = $FALSE;
        }

        $obj = New-IcingaPerformanceCounter -Counter $counter -SkipWait $TRUE;
        if ($CounterResult.ContainsKey($obj.Name()) -eq $FALSE) {
            $CounterResult.Add($obj.Name(), $obj.Value());
        }
    }

    # TODO: Add a cache for our Performance Counters to only fetch them once
    #       for each session to speed up the loading. This cold be something like
    #       this:
    #
    # $Global:Icinga.Public.PerformanceCounter.Cache += $CounterResult;

    # Above we initialise ever single counter and we only require a sleep once
    # in case a new, yet unknown counter was added
    if ($RequireSleep) {
        Start-Sleep -Milliseconds 500;

        # Agreed, this is some sort of code duplication but it wouldn't make
        # any sense to create a own function for this. Why are we doing
        # this anyway?
        # Simple: In case we found counters which have yet not been initialised
        #         we did this above. Now we have waited 500 ms to receive proper
        #         values from these counters. As the previous generated result
        #         might have contained counters with 0 results, we will now
        #         check all counters again to receive the proper values.
        #         Agreed, might sound like a overhead, but the impact only
        #         applies to the first call of the module with the counters.
        #         This 'duplication' however decreased the execution from
        #         certain modules from 25s to 1s on the first run. Every
        #         additional run is then being executed within 0.x s
        #         which sounds like a very good performance and solution
        $CounterResult = @{ };
        foreach ($counter in $CounterArray) {
            $obj = New-IcingaPerformanceCounter -Counter $counter -SkipWait $TRUE;
            if ($CounterResult.ContainsKey($obj.Name()) -eq $FALSE) {
                $CounterResult.Add($obj.Name(), $obj.Value());
            }
        }
    }

    return $CounterResult;
}
