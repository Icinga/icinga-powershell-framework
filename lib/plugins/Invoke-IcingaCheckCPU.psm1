Import-IcingaLib core\perfcounter;
Import-IcingaLib icinga\plugin;
Import-IcingaLib icinga\exception;

function Invoke-IcingaCheckCPU()
{
    param(
        $Warning,
        $Critical,
        $Core               = '*',
        [switch]$NoPerfData,
        $Verbose
    );

    $CpuCounter  = New-IcingaPerformanceCounter -Counter ([string]::Format('\Processor({0})\% processor time', $Core));
    $CpuPackage  = New-IcingaCheckPackage -Name 'CPU Load' -OperatorAnd -Verbos $Verbose;

    Exit-IcingaMissingPermission -Input $CpuCounter.ErrorMessage -StringPattern '"Global"' -ExeptionType $IcingaExceptions.Throw.PerformanceCounter;

    if ($CpuCounter.Counters.Count -ne 0) {
        foreach ($counter in $CpuCounter.Counters) {
            $IcingaCheck = New-IcingaCheck -Name ([string]::Format('Core #{0}', $counter.Instance)) -Value $counter.Value().Value -Unit '%';
            $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
            $CpuPackage.AddCheck($IcingaCheck);
        }
    } else {
        $IcingaCheck = New-IcingaCheck -Name ([string]::Format('Core #{0}',$Core)) -Value $CpuCounter.Value().Value -Unit '%';
        $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
        $CpuPackage.AddCheck($IcingaCheck);
    }

    exit (New-IcingaCheckResult -Name 'CPU Load' -Check $CpuPackage -NoPerfData $NoPerfData -Compile);
}
