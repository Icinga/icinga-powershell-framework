<#
 # This function will create a custom Performance Counter object with
 # already initialised counters, which can be accessed with the
 # following members:
 # Name
 # Value
 # Like the New-IcingaPerformanceCounterResult, this will allow to fetch the
 # current values of a single counter instance including the name
 # of the counter. Within the New-IcingaPerformanceCounterResult function,
 # objects created by this function are used.
 #>
 function New-IcingaPerformanceCounterObject()
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
 
        # TODO: Re-Implement debug logging
         <#$Icinga2.Log.Write(
             $Icinga2.Enums.LogState.Debug,
             [string]::Format('Creating new Counter for Category {0} with Instance {1} and Counter {2}. Full Name "{3}"',
                 $this.Category,
                 $this.Instance,
                 $this.Counter,
                 $this.FullName
             )
         );#>
 
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
