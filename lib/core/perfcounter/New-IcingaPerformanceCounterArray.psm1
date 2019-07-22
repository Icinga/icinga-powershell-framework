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
 function New-IcingaPerformanceCounterArray()
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
 