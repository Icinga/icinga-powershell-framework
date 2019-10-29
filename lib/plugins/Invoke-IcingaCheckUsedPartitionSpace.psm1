Import-IcingaLib core\perfcounter;
Import-IcingaLib icinga\plugin;

<#
.SYNOPSIS
   Checks how much space on a partition is used.
.DESCRIPTION
   Invoke-IcingaCheckUsedPartition returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
   e.g 'C:' is at 8% usage, WARNING is set to 60, CRITICAL is set to 80. In this case the check will return OK.
   More Information on https://github.com/LordHepipud/icinga-module-windows
.FUNCTIONALITY
   This module is intended to be used to check how much usage there is on an partition.
   Based on the thresholds set the status will change between 'OK', 'WARNING' or 'CRITICAL'. The function will return one of these given codes.
.EXAMPLE
   PS>Invoke-IcingaCheckUsedPartitionSpace -Warning 60 -Critical 80
   [OK]: Check package "Used Partition Space" is [OK]
   | 'Partition C'=8,06204986572266%;60;;0;100 'Partition D'=12,06204736572266%;60;;0;100 'Partition K'=19,062047896572266%;60;;0;100
.EXAMPLE
   PS>Invoke-IcingaCheckUsedPartitionSpace -Warning 60 -Critical 80 -Exclude "C:\"
   [OK]: Check package "Used Partition Space" is [OK]
   | 'Partition D'=12,06204736572266%;60;;0;100 'Partition K'=19,062047896572266%;60;;0;100
.EXAMPLE
   PS>Invoke-IcingaCheckUsedPartitionSpace -Warning 60 -Critical 80 -Include "C:\"
   [OK]: Check package "Used Partition Space" is [OK]
   | 'Partition C'=8,06204986572266%;60;;0;100
.PARAMETER Warning
   Used to specify a Warning threshold. In this case an integer value.
.PARAMETER Critical
   Used to specify a Critical threshold. In this case an integer value.
.PARAMETER Exclude
   Used to specify an array of partitions to be excluded.
   e.g. 'C:\','D:\'
.PARAMETER Include
   Used to specify an array of partitions to be included.
   e.g. 'C:\','D:\'
.INPUTS
   System.String
.OUTPUTS
   System.String
.LINK
   https://github.com/LordHepipud/icinga-module-windows
.NOTES
#>

function Invoke-IcingaCheckUsedPartitionSpace()
{
   param(
      [int]$Warning       = $null,
      [int]$Critical      = $null,
      [array]$Include     = @(),
      [array]$Exclude     = @(),
      [switch]$NoPerfData,
      [ValidateSet(0, 1, 2, 3)]
      [int]$Verbosity     = 0
   );

   $DiskFree = Get-IcingaDiskPartitions;
   $DiskPackage = New-IcingaCheckPackage -Name 'Used Partition Space' -OperatorAnd -Verbos $Verbosity;

   foreach ($Letter in $DiskFree.Keys) {
      if ($Include.Count -ne 0) {
         $Include = $Include.trim(' :/\');
         if (-Not ($Include.Contains($Letter))) {
               continue;
         }
      }


      if ($Exclude.Count -ne 0) {
         $Exclude = $Exclude.trim(' :/\');
         if ($Exclude.Contains($Letter)) {
               continue;
         }
      }

      $IcingaCheck = New-IcingaCheck -Name ([string]::Format('Partition {0}', $Letter)) -Value (100-($DiskFree.([string]::Format($Letter))."Free Space")) -Unit '%';
      $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
      $DiskPackage.AddCheck($IcingaCheck);
   }

   return (New-IcingaCheckResult -Check $DiskPackage -NoPerfData $NoPerfData -Compile);
}
