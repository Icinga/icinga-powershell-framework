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
   PS> 
.PARAMETER WarningBytes
   Used to specify a Warning threshold. In this case an string value.

   The string has to be like, "20B", "20KB", "20MB", "20GB", "20TB", "20TB"
.PARAMETER CriticalBytes
   Used to specify a Critical threshold. In this case an string value.

   The string has to be like, "20B", "20KB", "20MB", "20GB", "20TB", "20TB"

.PARAMETER Pagefile
   Switch which determines whether the pagefile should be used instead.
   If not set memory will be checked.

.PARAMETER CriticalPercent
   Used to specify a Critical threshold. In this case an integer value.

   Like 30 for 30%. If memory usage is below 30%, the check will return CRITICAL.

.PARAMETER CriticalPercent
   Used to specify a Critical threshold. In this case an integer value.

   Like 30 for 30%. If memory usage is below 30%, the check will return Warning.

.INPUTS
   System.String

.OUTPUTS
   System.String

.LINK
   https://github.com/LordHepipud/icinga-module-windows
.NOTES
#>

<#
if ($bytes > 1099511627776) { return sprintf('%.2f TB', $bytes / 1099511627776); } elseif ($bytes > 1073741824) { return sprintf('%.2f GB', $bytes / 1073741824); } elseif ($bytes > 1048576) { return sprintf('%.2f MB', $bytes / 1048576); } else { return sprintf('%.2f KB', $bytes / 1024);
#>

function Invoke-IcingaCheckMemory()
{
    param(
        [string]$CriticalBytes = $null,
        [string]$WarningBytes  = $null,
        $CriticalPercent       = $null,
        $WarningPercent        = $null,
#        [switch]$PageFile,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity        = 0,
        [switch]$NoPerfData
     );

   If ([string]::IsNullOrEmpty($CriticalBytes) -eq $FALSE) {
      $CrticalConvertedAll = Convert-Bytes $CriticalBytes -Unit B
      [decimal]$CriticalConverted = $CriticalConvertedAll.value

   }
   If ([string]::IsNullOrEmpty($WarningBytes) -eq $FALSE) {
      $WarningConvertedAll = Convert-Bytes $WarningBytes -Unit B
      [decimal]$WarningConverted = $WarningConvertedAll.value
   }

   $MemoryPackage = New-IcingaCheckPackage -Name 'Memory Usage' -OperatorAnd -Verbos $Verbosity;
   $MemoryData    = (Get-IcingaMemoryPerformanceCounter);

   # Auto-Detect?
   If (($MemoryData['Memory Total Bytes'] / [math]::Pow(2, 50)) -ge 1) {
      $Unit = "PB"
   } elseif (($MemoryData['Memory Total Bytes'] / [math]::Pow(2, 40)) -ge 1) {
      $Unit = "TB"
   } elseif (($MemoryData['Memory Total Bytes'] / [math]::Pow(2, 30)) -ge 1) {
      $Unit = "GB"
   } elseif (($MemoryData['Memory Total Bytes'] / [math]::Pow(2, 20)) -ge 1) {
      $Unit = "MB"
   } elseif (($MemoryData['Memory Total Bytes'] / [math]::Pow(2, 10)) -ge 1) {
      $Unit = "KB"
   } else {
      $Unit = "B"
   }

   Write-Host $Unit
  
   $MemoryPerc             = New-IcingaCheck -Name 'Memory Percent Used' -Value $MemoryData['Memory Used %'] -Unit '%';
   $MemoryByteUsed         = New-IcingaCheck -Name "Used Bytes" -Value $MemoryData['Memory Used Bytes'] -Unit 'B';
   #$MemoryByteAvailable    = New-IcingaCheck -Name "Available Bytes" -Value $MemoryData['Memory Available Bytes'] -Unit 'B';
   #$PageFileCheck          = New-IcingaCheck -Name 'PageFile Percent' -Value $MemoryData['PageFile %'] -Unit '%';


   #Kommastellen bedenken!
   # PageFile To-Do
   $MemoryByteUsed.WarnOutOfRange($WarningConverted).CritOutOfRange($CrticalConverted) | Out-Null;
   $MemoryPerc.WarnOutOfRange($WarningPercent).CritOutOfRange($CriticalPercent) | Out-Null;
   
   $MemoryPackage.AddCheck($MemoryPerc);
   #$MemoryPackage.AddCheck($MemoryByteAvailable);
   $MemoryPackage.AddCheck($MemoryByteUsed);

   #$MemoryPackage.AddCheck($PageFileCheck);
    
   return (New-IcingaCheckResult -Check $MemoryPackage -NoPerfData $NoPerfData -Compile);
}
