Import-IcingaLib icinga\plugin;
Import-IcingaLib provider\windows;
Import-IcingaLib core\tools;

<#
.SYNOPSIS
   Checks how long a Windows system has been up for.
.DESCRIPTION
   InvokeIcingaCheckUptime returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
   e.g 'C:\Users\Icinga\Backup' the system has been running for 10 days, WARNING is set to 15d, CRITICAL is set to 30d. In this case the check will return OK.
   More Information on https://github.com/LordHepipud/icinga-module-windows
.FUNCTIONALITY
   This module is intended to check how long a Windows system has been up for.
   Based on the thresholds set the status will change between 'OK', 'WARNING' or 'CRITICAL'. The function will return one of these given codes.
   
.EXAMPLE
   PS> Invoke-IcingaCheckUptime -Warning 18d -Critical 20d
   [WARNING]: Check package "Windows Uptime: Days: 19 Hours: 13 Minutes: 48 Seconds: 29" is [WARNING]
   | 'Windows Uptime'=1691309,539176s;1555200;1728000 
.PARAMETER IcingaCheckUsers_String_Warning
   Used to specify a Warning threshold. In this case a string.
   Allowed units include: ms, s, m, h, d, w, M, y
.PARAMETER IcingaCheckUsers_String_Critical
   Used to specify a Critical threshold. In this case a string.
   Allowed units include: ms, s, m, h, d, w, M, y
.INPUTS
   System.String
.OUTPUTS
   System.String
.LINK
   https://github.com/LordHepipud/icinga-module-windows
.NOTES
#>

function Invoke-IcingaCheckUptime()
{
   param(
      [string]$Warning    = $null,
      [string]$Critical   = $null,
      [switch]$NoPerfData,
      [ValidateSet(0, 1, 2, 3)]
      [int]$Verbosity     = 0
   );

   $WindowsData = Get-IcingaWindows;
   $Name        = ([string]::Format('Windows Uptime: {0}', (ConvertFrom-TimeSpan -Seconds $WindowsData.windows.metadata.uptime.value)));

   $IcingaCheck = New-IcingaCheck -Name 'Windows Uptime' -Value $WindowsData.windows.metadata.uptime.value -Unit 's';
   $IcingaCheck.WarnOutOfRange(
      (ConvertTo-SecondsFromIcingaThresholds -Threshold $Warning)
   ).CritOutOfRange(
      (ConvertTo-SecondsFromIcingaThresholds -Threshold $Critical)
   ) | Out-Null;

   $CheckPackage = New-IcingaCheckPackage -Name $Name -OperatorAnd -Checks $IcingaCheck -Verbose $Verbosity;

   return (New-IcingaCheckresult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}
