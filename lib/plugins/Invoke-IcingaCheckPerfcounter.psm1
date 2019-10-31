Import-IcingaLib icinga\plugin;

<#
.SYNOPSIS
   Performs checks on various performance counter
.DESCRIPTION
   Invoke-IcingaCheckDirectory returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
   Use "Show-IcingaPerformanceCounterCategories" to see all performance counter categories available.
   To gain insight on an specific performance counter use "Show-IcingaPerformanceCounters <performance counter category>"
   e.g '

   More Information on https://github.com/Icinga/icinga-powershell-framework
.FUNCTIONALITY
   This module is intended to be used to perform checks on different performance counter.
   Based on the thresholds set the status will change between 'OK', 'WARNING' or 'CRITICAL'. The function will return one of these given codes.
.EXAMPLE
   PS> Invoke-IcingaCheckPerfCounter -PerfCounter '\processor(*)\% processor time' -Warning 60 -Critical 90
   [WARNING]: Check package "Performance Counter" is [WARNING]
   | 'processor1_processor_time'=68.95;60;90 'processor3_processor_time'=4.21;60;90 'processor5_processor_time'=9.5;60;90 'processor_Total_processor_time'=20.6;60;90 'processor0_processor_time'=5.57;60;90 'processor2_processor_time'=0;60;90 'processor4_processor_time'=6.66;60;90
   1
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
   https://github.com/Icinga/icinga-powershell-framework
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
