Import-IcingaLib provider\process;
Import-IcingaLib icinga\plugin;

<#
.SYNOPSIS
   Checks how many processes of a process exist.

.DESCRIPTION
   Invoke-IcingaCheckDirectory returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
   e.g there are three conhost processes running, WARNING is set to 3, CRITICAL is set to 4. In this case the check will return WARNING.

   More Information on https://github.com/LordHepipud/icinga-module-windows

.FUNCTIONALITY
   This module is intended to be used to check how many processes of a process exist.
   Based on the thresholds set the status will change between 'OK', 'WARNING' or 'CRITICAL'. The function will return one of these given codes.

.EXAMPLE
   PS>Invoke-IcingaCheckProcessCount -Process conhost -Warning 5 -Critical 10
   [OK]: Check package "Process Check" is [OK]
   | 'Process Count "conhost"'=3;; 

.EXAMPLE
   PS>Invoke-IcingaCheckProcessCount -Process conhost,wininit -Warning 5 -Critical 10 -Verbose 4
   [OK]: Check package "Process Check" is [OK] (Match All)
    \_ [OK]: Process Count "conhost" is 3
    \_ [OK]: Process Count "wininit" is 1
   | 'Process Count "conhost"'=3;5;10 'Process Count "wininit"'=1;5;10

.PARAMETER Warning
   Used to specify a Warning threshold. In this case an integer value.

.PARAMETER Critical
   Used to specify a Critical threshold. In this case an integer value.

.PARAMETER Process
   Used to specify an array of processes to count and match against.
   e.g. conhost,wininit

.INPUTS
   System.String

.OUTPUTS
   System.String

.LINK
   https://github.com/LordHepipud/icinga-module-windows

.NOTES
#>

function Invoke-IcingaCheckProcessCount()
{
    param(
        [int]$Warning,
        [int]$Critical,
        [array]$Process,
        [switch]$NoPerfData,
        $Verbose
    );

    $ProcessInformation = (Get-IcingaProcessData -Name $Process)

    $ProcessPackage = New-icingaCheckPackage -Name "Process Check" -OperatorAnd -Verbose $Verbose -NoPerfData $NoPerfData;

    if ($Process.Count -eq 0) {
        $ProcessCount = $ProcessInformation['Process Count'];
        $IcingaCheck = New-IcingaCheck -Name ([string]::Format('Process Count')) -Value $ProcessCount;
        $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
        $ProcessPackage.AddCheck($IcingaCheck);
    } else {
        foreach ($proc in $process) {
            $ProcessCount = $ProcessInformation."Processes".$proc.processlist.Count;
            $IcingaCheck = New-IcingaCheck -Name ([string]::Format('Process Count "{0}"', $proc)) -Value $ProcessCount;
            $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
            $ProcessPackage.AddCheck($IcingaCheck);
        }
    }


    exit (New-IcingaCheckResult -Check $ProcessPackage -NoPerfData $NoPerfData -Compile);
}
