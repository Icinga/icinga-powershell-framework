Import-IcingaLib provider\memory;
Import-IcingaLib core\tools;

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
   PS> Invoke-IcingaCheckMemory -Unit GB -Critical 1850000KB -Warning 2500000KB -CriticalPercent 80 -WarningPercent 30 -Verbosity 3
   [Warning]: Check package "Memory Usage" is [Warning] (Match All)
    \_ [WARNING]: Memory Percent 35.95% is greater than 30%
    \_ [OK]: PageFile Percent is 16.42%
   | 'Memory_Percent'=35.95%;30;80;0;100 'Used_Bytes_in_GB'=3.44;2.5;1.85 'PageFile_Percent'=16.42%;;;0;100 
   1
.PARAMETER Warning
   Used to specify a Warning threshold. In this case an string value.

   The string has to be like, "20B", "20KB", "20MB", "20GB", "20TB", "20TB"
.PARAMETER Critical
   Used to specify a Critical threshold. In this case an string value.

   The string has to be like, "20B", "20KB", "20MB", "20GB", "20TB", "20TB"

.PARAMETER Pagefile
   Switch which determines whether the pagefile should be used instead.
   If not set memory will be checked.

.PARAMETER CriticalPercent
   Used to specify a Critical threshold. In this case an integer value.

   Like 30 for 30%. If memory usage is above 30%, the check will return CRITICAL.

.PARAMETER CriticalPercent
   Used to specify a Critical threshold. In this case an integer value.

   Like 30 for 30%. If memory usage is above 30%, the check will return Warning.

.PARAMETER Unit
   Determines output Unit. Allowed Units: 'B', 'KB', 'MB', 'GB', 'TB', 'PB'

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
        [string]$Critical   = $null,
        [string]$Warning    = $null,
        [string]$Unit       = 'B',
        $CriticalPercent    = $null,
        $WarningPercent     = $null,
        [switch]$PageFile,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity     = 0,
        [switch]$NoPerfData
     );

    $CrticalConverted = Convert-Bytes $Critical -Unit $Unit
    $WarningConverted = Convert-Bytes $Warning -Unit $Unit

    $MemoryPackage = New-IcingaCheckPackage -Name 'Memory Usage' -OperatorAnd -Verbos $Verbosity;
    $MemoryData    = (Get-IcingaMemoryPerformanceCounter);
  

    $MemoryPerc    = New-IcingaCheck -Name 'Memory Percent' -Value $MemoryData['Memory Used %'] -Unit '%';
    $MemoryByte    = New-IcingaCheck -Name "Used Bytes in $Unit" -Value (Convert-Bytes ([string]::Format('{0}B', $MemoryData['Memory used Bytes'])) -Unit $Unit);
    #$PageFileCheck = New-IcingaCheck -Name 'PageFile Percent' -Value $MemoryData['PageFile %'] -Unit '%';

    # PageFile To-Do
    $MemoryByte.WarnOutOfRange($WarningConverted).CritOutOfRange($CrticalConverted) | Out-Null;
    $MemoryPerc.WarnOutOfRange($WarningPercent).CritOutOfRange($CriticalPercent) | Out-Null;
    
    $MemoryPackage.AddCheck($MemoryPerc);
    $MemoryPackage.AddCheck($MemoryByte);
    #$MemoryPackage.AddCheck($PageFileCheck);
    
    return (New-IcingaCheckResult -Check $MemoryPackage -NoPerfData $NoPerfData -Compile);
}
