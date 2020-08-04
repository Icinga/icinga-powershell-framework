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
function New-IcingaPerformanceCounterResult()
{
    param(
        [string]$FullName           = '',
        [array]$PerformanceCounters = @()
    );

    $pc_instance = New-Object -TypeName PSObject;
    $pc_instance | Add-Member -MemberType NoteProperty -Name 'FullName' -Value $FullName;
    $pc_instance | Add-Member -MemberType NoteProperty -Name 'Counters' -Value $PerformanceCounters;

    $pc_instance | Add-Member -MemberType ScriptMethod -Name 'Name' -Value {
        return $this.FullName;
    }

    $pc_instance | Add-Member -MemberType ScriptMethod -Name 'Value' -Value {
        [hashtable]$CounterResults = @{};

        foreach ($counter in $this.Counters) {
            $CounterResults.Add($counter.Name(), $counter.Value());
        }

        return $CounterResults;
    }

    return $pc_instance;
}
