<#
.SYNOPSIS
    Will use an array of provided Performance Counter and sort the input by
    a given counter category. In this case we can fetch all Processor instances
    and receive values for each core which can then be accessed from a hashtable
    with an eady query. Allows to modify output in addition
.DESCRIPTION
    Will use an array of provided Performance Counter and sort the input by
    a given counter category. In this case we can fetch all Processor instances
    and receive values for each core which can then be accessed from a hashtable
    with an eady query. Allows to modify output in addition
.FUNCTIONALITY
    Will use an array of provided Performance Counter and sort the input by
    a given counter category. In this case we can fetch all Processor instances
    and receive values for each core which can then be accessed from a hashtable
    with an eady query. Allows to modify output in addition
.EXAMPLE
    PS>New-IcingaPerformanceCounterStructure -CounterCategory 'Processor' -PerformanceCounterHash (New-IcingaPerformanceCounterArray '\Processor(*)\% processor time');

    Name                           Value
    ----                           -----
    7                              {% processor time}
    3                              {% processor time}
    4                              {% processor time}
    _Total                         {% processor time}
    2                              {% processor time}
    1                              {% processor time}
    0                              {% processor time}
    6                              {% processor time}
    5                              {% processor time}
.EXAMPLE
    PS>New-IcingaPerformanceCounterStructure -CounterCategory 'Processor' -PerformanceCounterHash (New-IcingaPerformanceCounterArray '\Processor(*)\% processor time') -InstanceNameCleanupArray '_';

    Name                           Value
    ----                           -----
    7                              {% processor time}
    Total                          {}
    3                              {% processor time}
    4                              {% processor time}
    2                              {% processor time}
    1                              {% processor time}
    0                              {% processor time}
    6                              {% processor time}
    5                              {% processor time}
.PARAMETER CounterCategory
    The name of the category the sort algorithm will fetch the instances from for sorting
.PARAMETER PerformanceCounterHash
    An array of Performance Counter objects provided by 'New-IcingaPerformanceCounterArray' to sort for
.PARAMETER InstanceNameCleanupArray
    An array which will be used to remove string content from the sorted instances keys. For example '_' will change
    '_Total' to 'Total'. Replacements are done in the order added to this array
.INPUTS
    System.String
.OUTPUTS
    System.Hashtable
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>
function New-IcingaPerformanceCounterStructure()
{
    param(
        [string]$CounterCategory           = '',
        [hashtable]$PerformanceCounterHash = @{},
        [array]$InstanceNameCleanupArray   = @()
    )

    # The storage variables we require to store our data
    [array]$AvailableInstances        = @();
    [hashtable]$StructuredCounterData = @{};

    # With this little trick we can fetch all instances we have and get their unique name
    $CounterInstances = New-Object System.Diagnostics.PerformanceCounterCategory($CounterCategory);
    foreach ($instance in $CounterInstances.GetInstanceNames()) {
        # For some counters we require to apply a 'cleanup' for the instance name
        # Example Disks: Some disks are stored with the name
        # 'HarddiskVolume1'
        # To be able to map the volume correctly to disks, we require to remove
        # 'HarddiskVolume' so only '1' will remain, which allows us to map the
        # volume correctly afterwards
        [string]$CleanInstanceName = $instance;
        foreach ($cleanup in $InstanceNameCleanupArray) {
            $CleanInstanceName = $CleanInstanceName.Replace($cleanup, '');
        }
        $AvailableInstances += $CleanInstanceName;
    }

    # Now let the real magic begin.

    # At first we will loop all instances of our Performance Counters, which means all
    # instances we have found above. We build a new hashtable then to list the instances
    # by their individual name and all corresponding counters as children
    # This allows us a structured output with all data for each instance
    foreach ($instance in $AvailableInstances) {

        # First build a hashtable for each instance to add data to later
        $StructuredCounterData.Add($instance, @{});

        # Now we need to loop all return values from our Performance Counters
        foreach ($InterfaceCounter in $PerformanceCounterHash.Keys) {
            # As we just looped the parent counter (Instance *), we now need to
            # loop the actual counters for each instance
            foreach ($interface in $PerformanceCounterHash[$InterfaceCounter]) {
                # Finally let's loop through all the results which contain the values
                # to build our new, structured hashtable
                foreach ($entry in $interface.Keys) {
                    # Match the counters based on our current parent index
                    # (the instance name we want to add the values as children).
                    if ($entry.Contains('(' + $instance + ')')) {
                        # To ensure we don't transmit the entire counter name,
                        # we only want to include the name of the actual counter.
                        # There is no need to return
                        # \Network Interface(Desktopadapter Intel[R] Gigabit CT)\Bytes Received/sec
                        # the naming
                        # Bytes Received/sec
                        # is enough
                        [array]$TmpOutput = $entry.Split('\');
                        [string]$OutputName = $TmpOutput[$TmpOutput.Count - 1];

                        # Now add the actual value to our parent instance with the
                        # improved value name, including the sample and counter value data
                        $StructuredCounterData[$instance].Add($OutputName, $interface[$entry]);
                    }
                }
            }
        }
    }

    return $StructuredCounterData;
}
