<#
  # This function will make monitoring an entire list of
  # Performance counters even more easier. We simply provide
  # an array of Performance Counters  to this module
  # and we will receive a construct-save result of an
  # hashtable with all performance counters including
  # the corresponding values. In that case the code
  # size decreases for larger modules.
  # Example:
    $counter = New-IcingaPerformanceCounterArray @(
        '\Memory\Available Bytes',
        '\Memory\% Committed Bytes In Use'
    );
  #>
  function New-IcingaPerformanceCounterArray()
  {
      param(
          [array]$CounterArray = @()
      )
 
      [hashtable]$CounterResult = @{};
      [bool]$RequireSleep       = $TRUE;
      foreach ($counter in $CounterArray) {
         # We want to speed up things with loading, so we will check if a specified
         # Counter is already cached within our hashtable. If it is not, we sleep
         # at the end of the function the required 500ms and don't have to wait
         # NumOfCounters * 500 milliseconds for the first runs. This will speed
         # up the general loading of counters and will not require some fancy
         # pre-caching / configuration handler
         # TODO: Re-Implement caching for counters
         #if ($Icinga2.Cache.PerformanceCounter -ne $null) {
         #    if ($Icinga2.Cache.PerformanceCounter.ContainsKey($counter) -eq $TRUE) {
                 $RequireSleep = $FALSE;
         #    }
         #}
         $obj = New-IcingaPerformanceCounter -Counter $counter -SkipWait $TRUE;
         if ($CounterResult.ContainsKey($obj.Name()) -eq $FALSE) {
             $CounterResult.Add($obj.Name(), $obj.Value());
         }
      }
 
      # Above we initialse ever single counter and we only require a sleep once
      # in case a new, yet unknown counter was added
      if ($RequireSleep) {
         Start-Sleep -Milliseconds 500;
 
         # Agreed, this is some sort of code duplication but it wouldn't make
         # any sense to create a own function for this. Why are we doing
         # this anway?
         # Simple: In case we found counters which have yet not been initialised
         #         we did this above. Now we have waited 500 ms to receive proper
         #         values from these counters. As the previous generated result
         #         might have contained counters with 0 results, we will now
         #         check all counters again to receive the proper values.
         #         Agreed, might sound like a overhead, but the impact only
         #         applies to the first call of the module with the counters.
         #         This 'duplication' however decreased the execution from
         #         certain modules from 25s to 1s on the first run. Every
         #         additional run is then beeing executed within 0.x s
         #         which sounds like a very good performance and solution
         $CounterResult = @{};
         foreach ($counter in $CounterArray) {
             $obj = New-IcingaPerformanceCounter -Counter $counter -SkipWait $TRUE;
             if ($CounterResult.ContainsKey($obj.Name()) -eq $FALSE) {
                 $CounterResult.Add($obj.Name(), $obj.Value());
             }
         }
      }
 
      return $CounterResult;
  }
