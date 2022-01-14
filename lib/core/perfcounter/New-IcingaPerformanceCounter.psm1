<#
.SYNOPSIS
    Creates counter objects and sub-instances from a given Performance Counter
    Will return either a New-IcingaPerformanceCounterObject or New-IcingaPerformanceCounterResult
    which both contain the same members, allowing for dynamically use of objects
.DESCRIPTION
    Creates counter objects and sub-instances from a given Performance Counter
    Will return either a New-IcingaPerformanceCounterObject or New-IcingaPerformanceCounterResult
    which both contain the same members, allowing for dynamically use of objects
.FUNCTIONALITY
    Creates counter objects and sub-instances from a given Performance Counter
    Will return either a New-IcingaPerformanceCounterObject or New-IcingaPerformanceCounterResult
    which both contain the same members, allowing for dynamically use of objects
.EXAMPLE
    PS>New-IcingaPerformanceCounter -Counter '\Processor(*)\% processor time';

    FullName                       Counters
    --------                       --------
    \Processor(*)\% processor time {@{FullName=\Processor(2)\% processor time; Category=Processor; Instance=2; Counter=%...
.EXAMPLE
    PS>New-IcingaPerformanceCounter -Counter '\Processor(*)\% processor time' -SkipWait;
.PARAMETER Counter
    The path to the Performance Counter to fetch data for
.PARAMETER SkipWait
    Set this if no sleep is intended for initialising the counter. This can be useful
    if multiple counters are fetched during one call with this function if the sleep
    is done afterwards manually. A sleep is set to 500ms to ensure counter data is
    valid and contains an offset from previous/current values
.INPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function New-IcingaPerformanceCounter()
{
    param(
        [string]$Counter   = '',
        [boolean]$SkipWait = $FALSE
    );

    # Simply use the counter name, like
    # \Paging File(_total)\% Usage
    if ([string]::IsNullOrEmpty($Counter) -eq $TRUE) {
        return (New-IcingaPerformanceCounterNullObject -FullName $Counter -ErrorMessage 'Failed to initialise counter, as no counter was specified.');
    }

    [array]$CounterArray = $Counter.Split('\');
    [string]$UseCounterCategory = '';
    [string]$UseCounterName     = '';
    [string]$UseCounterInstance = '';

    # If we add the counter as it should be
    # \Paging File(_total)\% Usage
    # the first array element will be an empty string we can skip
    # Otherwise the name was wrong and we should not continue
    if (-Not [string]::IsNullOrEmpty($CounterArray[0])) {
        return (New-IcingaPerformanceCounterNullObject -FullName $Counter -ErrorMessage ([string]::Format('Failed to deserialize counter "{0}". It seems the leading "\" is missing.', $Counter)));
    }

    # In case our Performance Counter is containing instances, we should split
    # The content and read the instance and counter category out
    if ($CounterArray[1].Contains('(')) {
        [array]$TmpCounter  = $CounterArray[1].Split('(');
        $UseCounterCategory = $TmpCounter[0];
        $UseCounterInstance = $TmpCounter[1].Replace(')', '');
    } else {
        # Otherwise we only require the category
        $UseCounterCategory = $CounterArray[1];
    }

    # At last get the actual counter containing our values
    $UseCounterName = $CounterArray[2];

    # Now as we know how the counter path is constructed and has been split into
    # the different values, we need to know how to handle the instances of the counter

    # If we specify a instance with (*) we want the module to automatically fetch all
    # instances for this counter. This will result in an New-IcingaPerformanceCounterResult
    # which contains the parent name including counters for all instances that
    # have been found
    if ($UseCounterInstance -eq '*') {
        # In case we already loaded the counters once, return the finished array
        $CachedCounter = Get-IcingaPerformanceCounterCacheItem -Counter $Counter;

        if ($null -ne $CachedCounter) {
            return (New-IcingaPerformanceCounterResult -FullName $Counter -PerformanceCounters $CachedCounter);
        }

        # If we need to build the array, load all instances from the counters and
        # create single performance counters and add them to a custom array and
        # later to a custom object
        try {
            [array]$AllCountersInstances = @();
            $CounterInstances = New-Object System.Diagnostics.PerformanceCounterCategory($UseCounterCategory);
            foreach ($instance in $CounterInstances.GetInstanceNames()) {
                [string]$NewCounterName = $Counter.Replace('*', $instance);
                $NewCounter             = New-IcingaPerformanceCounterObject -FullName $NewCounterName -Category $UseCounterCategory -Counter $UseCounterName -Instance $instance -SkipWait $TRUE;
                $AllCountersInstances += $NewCounter;
            }
        } catch {
            # Throw an exception in case our permissions are not enough to fetch performance counter
            Exit-IcingaThrowException -InputString $_.Exception -StringPattern 'System.UnauthorizedAccessException' -ExceptionType 'Permission' -ExceptionThrown $IcingaExceptions.Permission.PerformanceCounter;
            Exit-IcingaThrowException -InputString $_.Exception -StringPattern 'System.InvalidOperationException'   -ExceptionType 'Input'     -CustomMessage $Counter -ExceptionThrown $IcingaExceptions.Inputs.PerformanceCounter;
            Exit-IcingaThrowException -InputString $_.Exception -StringPattern '' -ExceptionType 'Unhandled';
            # Shouldn't actually get down here anyways
            return (New-IcingaPerformanceCounterNullObject -FullName $Counter -ErrorMessage ([string]::Format('Failed to deserialize instances for counter "{0}". Exception: "{1}".', $Counter, $_.Exception.Message)));
        }

        # If we load multiple instances, we should add a global wait here instead of a wait for each single instance
        # This will speed up CPU loading for example with plenty of cores available
        if ($SkipWait -eq $FALSE) {
            Start-Sleep -Milliseconds 500;
        }

        # Add the parent counter including the array of Performance Counters to our
        # caching mechanism and return the New-IcingaPerformanceCounterResult object for usage
        # within the monitoring modules
        Add-IcingaPerformanceCounterCache -Counter $Counter -Instances $AllCountersInstances;
        return (New-IcingaPerformanceCounterResult -FullName $Counter -PerformanceCounters $AllCountersInstances);
    } else {
        # This part will handle the counters without any instances as well as
        # specifically assigned instances, like (_Total) CPU usage.

        # In case we already have the counter within our cache, return the
        # cached informations
        $CachedCounter = Get-IcingaPerformanceCounterCacheItem -Counter $Counter;

        if ($null -ne $CachedCounter) {
            return $CachedCounter;
        }

        # If the cache is not present yet, create the Performance Counter object,
        # and add it to our cache
        $NewCounter = New-IcingaPerformanceCounterObject -FullName $Counter -Category $UseCounterCategory -Counter $UseCounterName -Instance $UseCounterInstance -SkipWait $SkipWait;
        Add-IcingaPerformanceCounterCache -Counter $Counter -Instances $NewCounter;
    }

    # This function will always return non-instance counters or
    # specifically defined instance counters. Performance Counter Arrays
    # are returned within their function. This is just to ensure that the
    # function looks finished from developer point of view
    return (Get-IcingaPerformanceCounterCacheItem -Counter $Counter);
}
