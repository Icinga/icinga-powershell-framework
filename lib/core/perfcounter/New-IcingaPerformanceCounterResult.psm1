<#
.SYNOPSIS
    Will provide a virtual object, containing an array of Performance Counters.
    The object has the following members:
    * Name
    * Value
.DESCRIPTION
    Will provide a virtual object, containing an array of Performance Counters.
    The object has the following members:
    * Name
    * Value
.FUNCTIONALITY
    Will provide a virtual object, containing an array of Performance Counters.
    The object has the following members:
    * Name
    * Value
.EXAMPLE
    PS>New-IcingaPerformanceCounterResult -FullName '\Processor(*)\% processor time' -PerformanceCounters $PerformanceCounters;
.PARAMETER FullName
    The full path to the Performance Counter
.PARAMETER PerformanceCounters
    A list of all instances/counters for the given Performance Counter
.INPUTS
    System.String
.OUTPUTS
    System.PSObject
.LINK
   https://github.com/Icinga/icinga-powershell-framework
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
        [hashtable]$CounterResults = @{ };

        foreach ($counter in $this.Counters) {
            $CounterResults.Add($counter.Name(), $counter.Value());
        }

        return $CounterResults;
    }

    return $pc_instance;
}
