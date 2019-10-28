Import-IcingaLib core\perfcounter;
Import-IcingaLib core\tools;
Import-IcingaLib icinga\plugin;

<#
.SYNOPSIS
   Checks cpu usage of cores.
.DESCRIPTION
   Invoke-IcingaCheckCPU returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
   e.g A system has 4 cores, each running at 60% usage, WARNING is set to 50%, CRITICAL is set to 75%. In this case the check will return WARNING.
   More Information on https://github.com/LordHepipud/icinga-module-windows
.FUNCTIONALITY
   This module is intended to be used to check on the current cpu usage of a specified core.
   Based on the thresholds set the status will change between 'OK', 'WARNING' or 'CRITICAL'. The function will return one of these given codes.
.EXAMPLE
   PS>Invoke-IcingaCheckCpu -Warning 50 -Critical 75
   [OK]: Check package "CPU Load" is [OK]
   | 'Core #0'=4,588831%;50;75;0;100 'Core #1'=0,9411243%;50;75;0;100 'Core #2'=11,53223%;50;75;0;100 'Core #3'=4,073013%;50;75;0;100
.EXAMPLE
   PS>Invoke-IcingaCheckCpu -Warning 50 -Critical 75 -Core 1  
   [OK]: Check package "CPU Load" is [OK]
   | 'Core #1'=2,612651%;50;75;0;100 
.PARAMETER Warning
   Used to specify a Warning threshold. In this case an integer value.
.PARAMETER Critical
   Used to specify a Critical threshold. In this case an integer value.
.PARAMETER Core
   Used to specify a single core to check on.
.INPUTS
   System.String
.OUTPUTS
   System.String
.LINK
   https://github.com/LordHepipud/icinga-module-windows
.NOTES
#>

function Invoke-IcingaCheckCPU()
{
    param(
        [int]$Warning,
        [int]$Critical,
        $Core               = '*',
        [switch]$NoPerfData,
        $Verbose
    );

    $CpuCounter  = New-IcingaPerformanceCounter -Counter ([string]::Format('\Processor({0})\% processor time', $Core));
    $CpuPackage  = New-IcingaCheckPackage -Name 'CPU Load' -OperatorAnd -Verbos $Verbose;
    $CpuCount    = ([string](Get-IcingaCpuCount)).Length;

    if ($CpuCounter.Counters.Count -ne 0) {
        foreach ($counter in $CpuCounter.Counters) {
            $IcingaCheck = New-IcingaCheck -Name ([string]::Format('Core {0}', (Format-IcingaDigitCount $counter.Instance.Replace('_', '') -Digits $CpuCount -Symbol ' '))) -Value $counter.Value().Value -Unit '%';
            $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
            $CpuPackage.AddCheck($IcingaCheck);
        }
    } else {
        $IcingaCheck = New-IcingaCheck -Name ([string]::Format('Core {0}', (Format-IcingaDigitCount $Core.Replace('_', '') -Digits $CpuCount -Symbol ' '))) -Value $CpuCounter.Value().Value -Unit '%';
        $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
        $CpuPackage.AddCheck($IcingaCheck);
    }

    return (New-IcingaCheckResult -Name 'CPU Load' -Check $CpuPackage -NoPerfData $NoPerfData -Compile);
}
