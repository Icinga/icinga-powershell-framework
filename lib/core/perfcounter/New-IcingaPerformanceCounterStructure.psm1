#
# This function will get handy in case we want to fetch Counters
# which have instances which might be helpful to group by their
# instances name. This will apply to Disk and Network Interface
# outputs for example, as it would be helpful to combine all
# counter results for a specific disk / interface in one
# result for easier working with these informations
#
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
