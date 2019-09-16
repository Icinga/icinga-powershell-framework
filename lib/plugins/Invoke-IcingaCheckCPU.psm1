Import-IcingaLib core\perfcounter;
Import-IcingaLib core\tools;
Import-IcingaLib icinga\plugin;

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

    if ($CpuCounter.Counters.Count -ne 0) {
        foreach ($counter in $CpuCounter.Counters) {
            $IcingaCheck = New-IcingaCheck -Name ([string]::Format('Core {0}', (Format-IcingaDigitCount $counter.Instance -Digits ([string](Get-IcingaCpuCount)).Length -Symbol ' '))) -Value $counter.Value().Value -Unit '%';
            $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
            $CpuPackage.AddCheck($IcingaCheck);
        }
    } else {
        $IcingaCheck = New-IcingaCheck -Name ([string]::Format('Core {0}', (Format-IcingaDigitCount $Core -Digits ([string](Get-IcingaCpuCount)).Length -Symbol ' '))) -Value $CpuCounter.Value().Value -Unit '%';
        $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
        $CpuPackage.AddCheck($IcingaCheck);
    }

    exit (New-IcingaCheckResult -Name 'CPU Load' -Check $CpuPackage -NoPerfData $NoPerfData -Compile);
}
