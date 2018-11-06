param(
    [string]$Counter                           = '',
    [string]$ListCounter                       = '',
    [array]$CounterArray                       = @(),
    [boolean]$ListCategories                   = $FALSE,
    [boolean]$SkipWait                         = $FALSE,
    # These arguments apply to CreateStructuredPerformanceCounterTable
    # This is the category name we want to create a structured output
    # Example: 'Network Interface'
    [string]$CreateStructuredOutputForCategory = '',
    # This is the hashtable of Performance Counters, created by
    # PerformanceCounterArray
    [hashtable]$StructuredCounterInput         = @{},
    # This argument is just a helper to replace certain strings within
    # a instance name with simply nothing.
    # Example: 'HarddiskVolume1' => '1'
    [array]$StructuredCounterInstanceCleanup   = @()
);

# This is our internal cache for Performance Counters already loaded
# In case the Icinga Agent is running as daemon, this hashtable is
# already initialised at the beginning. But if we run the Agent
# from the Powershell directly, we will require to build this cache
# within the environment to work properly and to receive valid data
if ($Icinga2.Cache.PerformanceCounter -eq $null) {
    $Icinga2.Log.Write(
        $Icinga2.Enums.LogState.Debug,
        'Creating new performance counter cache'
    );
    $Icinga2.Cache.PerformanceCounter = @{};
}

$Icinga2.Log.Write(
    $Icinga2.Enums.LogState.Debug,
    [string]::Format(
        'Performance Counter Cache content {0}',
        ($Icinga2.Cache.PerformanceCounter | Out-String)
    )
);

<#
 # This function will provide a virtual object, containing an array
 # of Performance Counters. The object has the following members:
 # Name
 # Value
 # This will ensure we will not have to worry about looping an array
 # of mutltiple instances within a counter handler, because this
 # function will deal with everything, returning an hashtable
 # containing the parent counter name including the values and
 # samples for every single instance
 #>
function PerformanceCounterArray()
{
    param(
        [string]$FullName           = '',
        [array]$PerformanceCounters = @()
    );

    $pc_instance = New-Object -TypeName PSObject;
    $pc_instance | Add-Member -membertype NoteProperty -name 'FullName' -value $FullName;
    $pc_instance | Add-Member -membertype NoteProperty -name 'Counters' -value $PerformanceCounters;

    $pc_instance | Add-Member -membertype ScriptMethod -name 'Name' -value {
        return $this.FullName;
    }

    $pc_instance | Add-Member -membertype ScriptMethod -name 'Value' -value {
        [hashtable]$CounterResults = @{};

        foreach ($counter in $this.Counters) {
            $CounterResults.Add($counter.Name(), $counter.Value());
        }

        return $CounterResults;
    }

    return $pc_instance;
}

<#
 # This function will create a custom Performance Counter object with
 # already initialised counters, which can be accessed with the
 # following members:
 # Name
 # Value
 # Like the PerformanceCounterArray, this will allow to fetch the
 # current values of a single counter instance including the name
 # of the counter. Within the PerformanceCounterArray function,
 # objects created by this function are used.
 #>
function PerformanceCounterObject()
{
    param(
        [string]$FullName  = '',
        [string]$Category  = '',
        [string]$Instance  = '',
        [string]$Counter   = '',
        [boolean]$SkipWait = $FALSE
    );

    $pc_instance = New-Object -TypeName PSObject;
    $pc_instance | Add-Member -membertype NoteProperty -name 'FullName'    -value $FullName;
    $pc_instance | Add-Member -membertype NoteProperty -name 'Category'    -value $Category;
    $pc_instance | Add-Member -membertype NoteProperty -name 'Instance'    -value $Instance;
    $pc_instance | Add-Member -membertype NoteProperty -name 'Counter'     -value $Counter;
    $pc_instance | Add-Member -membertype NoteProperty -name 'PerfCounter' -value $Counter;
    $pc_instance | Add-Member -membertype NoteProperty -name 'SkipWait'    -value $SkipWait;

    $pc_instance | Add-Member -membertype ScriptMethod -name 'Init' -value {

        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Debug,
            [string]::Format('Creating new Counter for Category {0} with Instance {1} and Counter {2}. Full Name "{3}"',
                $this.Category,
                $this.Instance,
                $this.Counter,
                $this.FullName
            )
        );

        # Create the Performance Counter object we want to access
        $this.PerfCounter              = New-Object System.Diagnostics.PerformanceCounter;
        $this.PerfCounter.CategoryName = $this.Category;
        $this.PerfCounter.CounterName  = $this.Counter;

        # Only add an instance in case it is defined
        if ([string]::IsNullOrEmpty($this.Instance) -eq $FALSE) {
            $this.PerfCounter.InstanceName = $this.Instance
        }

        # Initialise the counter
        try {
            $this.PerfCounter.NextValue() | Out-Null;
        } catch {
            # Nothing to do here, will be handled later
        }

        <#
         # For some counters we require to wait a small amount of time to receive proper data
         # Other counters do not need these informations and we do also not require to wait
         # for every counter we use, once the counter is initialised within our environment.
         # This will allow us to skip the sleep to speed up loading counters
         #>
        if ($this.SkipWait -eq $FALSE) {
            Start-Sleep -Milliseconds 500;
        }
    }

    # Return the name of the counter as string
    $pc_instance | Add-Member -membertype ScriptMethod -name 'Name' -value {
        return $this.FullName;
    }

    <#
     # Return a hashtable containting the counter value including the
     # Sample values for the counter itself. In case we run into an error,
     # keep the counter construct but add an error message in addition.
     #>
    $pc_instance | Add-Member -membertype ScriptMethod -name 'Value' -value {
        [hashtable]$CounterData = @{};

        try {
            [string]$CounterType = $this.PerfCounter.CounterType;
            $CounterData.Add('value',  $this.PerfCounter.NextValue());
            $CounterData.Add('sample', $this.PerfCounter.NextSample());
            $CounterData.Add('help',   $this.PerfCounter.CounterHelp);
            $CounterData.Add('type',   $CounterType);
            $CounterData.Add('error',  $null);
        } catch {
            $CounterData = @{};
            $CounterData.Add('value',  $null);
            $CounterData.Add('sample', $null);
            $CounterData.Add('help',   $null);
            $CounterData.Add('type',   $null);
            $CounterData.Add('error',  $_.Exception.Message);
        }

        return $CounterData;
    }

    # Initialiste the entire counter and internal handlers
    $pc_instance.Init();

    # Return this custom object
    return $pc_instance;
}

<#
 # If some informations are missing, it could happen that
 # we are unable to create a Performance Counter.
 # In this case we will use this Null Object, containing
 # the same member functions but allowing us to maintain
 # stability without unwanted exceptions
 #>
 function PerformanceCounterNullObject()
 {
     param(
         [string]$FullName     = '',
         [string]$ErrorMessage = ''
     );

     $pc_instance = New-Object -TypeName PSObject;
     $pc_instance | Add-Member -membertype NoteProperty -name 'FullName'     -value $FullName;
     $pc_instance | Add-Member -membertype NoteProperty -name 'ErrorMessage' -value $ErrorMessage;

     $pc_instance | Add-Member -membertype ScriptMethod -name 'Name' -value {
         return $this.FullName;
     }

     $pc_instance | Add-Member -membertype ScriptMethod -name 'Value' -value {
         [hashtable]$ErrorMessage = @{};

         $ErrorMessage.Add('value',  $null);
         $ErrorMessage.Add('sample', $null);
         $ErrorMessage.Add('help',   $null);
         $ErrorMessage.Add('type',   $null);
         $ErrorMessage.Add('error',  $this.ErrorMessage);

         return $ErrorMessage;
     }

     return $pc_instance;
 }

 <#
  # This function will make monitoring an entire list of
  # Performance counters even more easier. We simply provide
  # an array of Performance Counters  to this module
  # and we will receive a construct-save result of an
  # hashtable with all performance counters including
  # the corresponding values. In that case the code
  # size decreases for larger modules.
  # Example:
    $counter = Get-Icinga-Counter -CounterArray @(
        '\Memory\Available Bytes',
        '\Memory\% Committed Bytes In Use'
    );
  #>
 function CreatePerformanceCounterResult()
 {
     param(
         [array]$CounterArray = @()
     )

     [hashtable]$CounterResult = @{};
     [bool]$RequireSleep       = $FALSE;
     foreach ($counter in $CounterArray) {
        # We want to speed up things with loading, so we will check if a specified
        # Counter is already cached within our hashtable. If it is not, we sleep
        # at the end of the function the required 500ms and don't have to wait
        # NumOfCounters * 500 milliseconds for the first runs. This will speed
        # up the general loading of counters and will not require some fancy
        # pre-caching / configuration handler
        if ($Icinga2.Cache.PerformanceCounter -ne $null) {
            if ($Icinga2.Cache.PerformanceCounter.ContainsKey($counter) -eq $FALSE) {
                $RequireSleep = $TRUE;
            }
        }
        $obj = CreatePerformanceCounter -Counter $counter -SkipWait $TRUE;
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
            $obj = CreatePerformanceCounter -Counter $counter -SkipWait $TRUE;
            if ($CounterResult.ContainsKey($obj.Name()) -eq $FALSE) {
                $CounterResult.Add($obj.Name(), $obj.Value());
            }
        }
     }

     return $CounterResult;
 }

<#
 # This is the main function which is called from this script, constructing our counters
 # and loading possible sub-instances from our Performance Counter.
 # It will return either an PerformanceCounterObject or PerformanceCounterArray
 # which both contain the same members, allowing us to dynamicly use the objects
 # without having to worry about exception.
 #>
function CreatePerformanceCounter()
{
    param(
        [string]$Counter   = '',
        [boolean]$SkipWait = $FALSE
    );

    # Simply use the counter name, like
    # \Paging File(_total)\% Usage
    if ([string]::IsNullOrEmpty($Counter) -eq $TRUE) {
        return (PerformanceCounterNullObject -FullName $Counter -ErrorMessage 'Failed to initialise counter, as no counter was specified.');
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
        return (PerformanceCounterNullObject -FullName $Counter -ErrorMessage ([string]::Format('Failed to deserialize counter "{0}". It seems the leading "\" is missing.', $Counter)));
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

    # Now as we know how the counter path is constructed and has been splitted into
    # the different values, we need to know how to handle the instances of the counter

    # If we specify a instance with (*) we want the module to automaticly fetch all
    # instances for this counter. This will result in an PerformanceCounterArray
    # which contains the parent name including counters for all instances that
    # have been found
    if ($UseCounterInstance -eq '*') {
        # In case we already loaded the counters once, return the finished array
        if ($Icinga2.Cache.PerformanceCounter.ContainsKey($Counter) -eq $TRUE) {
            return (PerformanceCounterArray -FullName $Counter -PerformanceCounters $Icinga2.Cache.PerformanceCounter[$Counter]);
        }

        # If we need to build the array, load all instances from the counters and
        # create single performance counters and add them to a custom array and
        # later to a custom object
        try {
            [array]$AllCountersIntances = @();
            $CounterInstances = New-Object System.Diagnostics.PerformanceCounterCategory($UseCounterCategory);
            foreach ($instance in $CounterInstances.GetInstanceNames()) {
                [string]$NewCounterName = $Counter.Replace('*', $instance);
                $NewCounter             = PerformanceCounterObject -FullName $NewCounterName -Category $UseCounterCategory -Counter $UseCounterName -Instance $instance -SkipWait $SkipWait;
                $AllCountersIntances += $NewCounter;
            }
        } catch {
            return (PerformanceCounterNullObject -FullName $Counter -ErrorMessage ([string]::Format('Failed to deserialize instances for counter "{0}". Exception: "{1}".', $Counter, $_.Exception.Message)));
        }

        # Add the parent counter including the array of Performance Counters to our
        # caching mechanism and return the PerformanceCounterArray object for usage
        # within the monitoring modules
        $Icinga2.Cache.PerformanceCounter.Add($Counter, $AllCountersIntances);
        return (PerformanceCounterArray -FullName $Counter -PerformanceCounters $AllCountersIntances);
    } else {
        # This part will handle the counters without any instances as well as
        # specificly assigned instances, like (_Total) CPU usage.

        # In case we already have the counter within our cache, return the
        # cached informations
        if ($Icinga2.Cache.PerformanceCounter.ContainsKey($Counter) -eq $TRUE) {
            return $Icinga2.Cache.PerformanceCounter[$Counter];
        }

        # If the cache is not present yet, create the Performance Counter object,
        # and add it to our cache
        $NewCounter = PerformanceCounterObject -FullName $Counter -Category $UseCounterCategory -Counter $UseCounterName -Instance $UseCounterInstance -SkipWait $SkipWait;
        $Icinga2.Cache.PerformanceCounter.Add($Counter, $NewCounter);
    }

    # This function will always return non-instance counters or
    # specificly defined instance counters. Performance Counter Arrays
    # are returned within their function. This is just to ensure that the
    # function looks finished from developer point of view
    return $Icinga2.Cache.PerformanceCounter[$Counter];
}

#
# This function will get handy in case we want to fetch Counters
# which have instances which might be helpful to group by their
# instances name. This will apply to Disk and Network Interface
# outputs for example, as it would be helpful to combine all
# counter results for a specific disk / interface in one
# result for easier working with these informations
#
function CreateStructuredPerformanceCounterTable
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

#
# This function will load all available Categories of Performance Counters
# from the registry and outputs them. This will ensure we can fetch the real
# english names instead of the localiced ones
#
function ListCounterCategories()
{
    $RegistryData    = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Perflib\009' `
                                        -Name 'counter' | Select-Object -ExpandProperty Counter;
    [array]$Counters = @();

    # Now lets loop our registry data and fetch only for counter categories
    # Ignore everything else and drop the information
    foreach ($counter in $RegistryData) {
        # First filter out the ID's of the performance counter
        if (-Not ($counter -match "^[\d\.]+$") -And [string]::IsNullOrEmpty($counter) -eq $FALSE) {
            # Now check if the value we got is a counter category
            if ([System.Diagnostics.PerformanceCounterCategory]::Exists($counter) -eq $TRUE) {
                $Counters += $counter;
            }
        }
    }

    return $Counters;
}

#
# Provide the name of a category to fetch all available counters and
# if there are any instances assigned to it
#
function ListCountersFromCategory()
{
    param ([string]$CounterCategory);

    [hashtable]$counters = @{};
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

    return $counters;
}

if ([string]::IsNullOrEmpty($CreateStructuredOutputForCategory) -eq $FALSE) {
    return (CreateStructuredPerformanceCounterTable `
                -CounterCategory $CreateStructuredOutputForCategory `
                -PerformanceCounterHash $StructuredCounterInput `
                -InstanceNameCleanupArray $StructuredCounterInstanceCleanup
            )
}

if ($ListCategories -eq $TRUE) {
    return ListCounterCategories;
}

if ([string]::IsNullOrEmpty($ListCounter) -eq $FALSE) {
    return ListCountersFromCategory -CounterCategory $ListCounter;
}

# Make things easier by simply proividing an array of Performance Counter
# Names we wish to monitor
if ($CounterArray.Count -ne 0) {
    return (CreatePerformanceCounterResult -CounterArray $CounterArray);
}

return CreatePerformanceCounter -Counter $Counter -SkipWait $SkipWait;