Import-IcingaLib icinga\plugin;

<#
.SYNOPSIS
   Performs checks on various performance counter
.DESCRIPTION
   Invoke-IcingaCheckDirectory returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
   e.g 

   More Information on https://github.com/LordHepipud/icinga-module-windows
.FUNCTIONALITY
   This module is intended to be used to perform checks on different performance counter.
   Based on the thresholds set the status will change between 'OK', 'WARNING' or 'CRITICAL'. The function will return one of these given codes.
.EXAMPLE
   PS>
.EXAMPLE
   PS>
.EXAMPLE
   PS>
.EXAMPLE
   PS>
.PARAMETER Warning
   Used to specify a Warning threshold. In this case an ??? value.
.PARAMETER Critical
   Used to specify a Critical threshold. In this case an ??? value.
.PARAMETER PerfCounter
   Used to specify an array of performance counter to check against.
.INPUTS
   System.String
.OUTPUTS
   System.String
.LINK
   https://github.com/LordHepipud/icinga-module-windows
.NOTES
#>

function Invoke-IcingaCheckPerfcounter()
{
    param(
        [array]$PerfCounter,
        $Warning             = $null,
        $Critical            = $null,
        [switch]$NoPerfData,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity      = 0
    );

    $Counters     = New-IcingaPerformanceCounterArray -CounterArray $PerfCounter;
    $CheckPackage = New-IcingaCheckPackage -Name 'Performance Counter' -OperatorAnd -Verbose $Verbosity;

    foreach ($counter in $Counters.Keys) {

        $CounterPackage = New-IcingaCheckPackage -Name $counter -OperatorAnd -Verbose $Verbosity;

        foreach ($instanceName in $Counters[$counter].Keys) {
            $instance = $Counters[$counter][$instanceName];
            if ($instance -isnot [hashtable]) {
                $IcingaCheck  = New-IcingaCheck -Name $counter -Value $Counters[$counter].Value;
                $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
                $CounterPackage.AddCheck($IcingaCheck);
                break;
            }
            $IcingaCheck  = New-IcingaCheck -Name $instanceName -Value $instance.Value;
            $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
            $CounterPackage.AddCheck($IcingaCheck);
        }
        $CheckPackage.AddCheck($CounterPackage);
    }

    return (New-IcingaCheckresult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}
