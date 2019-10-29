Import-IcingaLib provider\memory;

<#
.SYNOPSIS
   Checks on memory usage
.DESCRIPTION
   Invoke-IcingaCheckMemory returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
   e.g memory is currently at 60% usage, WARNING is set to 50, CRITICAL is set to 90. In this case the check will return WARNING.

   More Information on https://github.com/LordHepipud/icinga-module-windows
.FUNCTIONALITY
   This module is intended to be used to check on memory usage.
   Based on the thresholds set the status will change between 'OK', 'WARNING' or 'CRITICAL'. The function will return one of these given codes.
.EXAMPLE
   PS>Invoke-IcingaCheckMemory -Verbosity 3 -Warning 60 -Critical 80
   [WARNING]: % Memory Check 78.74 is greater than 60
   1
.EXAMPLE
   PS> Invoke-IcingaCheckMemory -Verbosity 3 -Warning 60 -Critical 80 -PageFile
   [OK]: % Memory Check is 10.99
   0
.PARAMETER Warning
   Used to specify a Warning threshold. In this case an integer value.
.PARAMETER Critical
   Used to specify a Critical threshold. In this case an integer value.
.PARAMETER Pagefile
   Switch which determines whether the pagefile should be used instead.
   If not set memory will be checked.
.INPUTS
   System.String
.OUTPUTS
   System.String
.LINK
   https://github.com/LordHepipud/icinga-module-windows
.NOTES
#>

function Invoke-IcingaCheckMemory()
{
    param(
        $Critical           = $null,
        $Warning            = $null,
        [switch]$PageFile,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity     = 0
     );

    if ($PageFile -eq $TRUE) {
        $MemoryData = (Get-IcingaPageFilePerformanceCounter).'(*)\% usage'.'\Paging File(_Total)\% usage'.value
    } else {
        $MemoryData = (Get-IcingaMemoryPerformanceCounter).'% committed bytes in use'.value;
    }

    $MemoryCheck = New-IcingaCheck -Name '% Memory Check' -Value $MemoryData -NoPerfData;

    $MemoryCheck.WarnOutOfRange(
        ($Warning)
     ).CritOutOfRange(
        ($Critical)
     ) | Out-Null;

     return (New-IcingaCheckresult -Check $MemoryCheck -NoPerfData $TRUE -Compile);
}