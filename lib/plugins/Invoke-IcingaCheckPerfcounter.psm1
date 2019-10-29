Import-IcingaLib icinga\plugin;

function Invoke-IcingaCheckPerfcounter()
{
    param(
        [array]$PerfCounter,
        [double]$Warning      = $null,
        [double]$Critical     = $null,
        [switch]$NoPerfData,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity       = 0
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
