Import-IcingaLib provider\services;
Import-IcingaLib provider\enums;
Import-IcingaLib icinga\plugin;

<#
.SYNOPSIS
   Checks if a service has a specified status.
.DESCRIPTION
   Invoke-icingaCheckService returns either 'OK' or 'CRITICAL', if a service status is matching status to be checked.
   More Information on https://github.com/LordHepipud/icinga-module-windows
.FUNCTIONALITY
   This module is intended to be used to check whether one or more services have a certain status. 
   As soon as one of the specified services does not match the status, the function returns 'CRITICAL' instead of 'OK'.
.EXAMPLE
   PS>Invoke-IcingaCheckService -Service WiaRPC, Spooler -Status '1' -Verbose 3
   [CRITICAL]: Check package "Services" is [CRITICAL] (Match All)
    \_ [OK]: Service "Ereignisse zum Abrufen von Standbildern (WiaRPC)" is Stopped
    \_ [CRITICAL]: Service "Druckwarteschlange (Spooler)" Running is not matching Stopped
.PARAMETER Service
   Used to specify an array of services which should be checked against the status.
   Seperated with ','
.PARAMETER Status
   Status for the specified service or services to check against.
.INPUTS
   System.Array
.OUTPUTS
   System.String
.LINK
   https://github.com/LordHepipud/icinga-module-windows
.NOTES
#>

function Invoke-IcingaCheckService()
{
   param(
      [array]$Service,
      [ValidateSet('Stopped', 'StartPending', 'StopPending', 'Running', 'ContinuePending', 'PausePending', 'Paused')]
      [string]$Status = 'Running',
      [ValidateSet(0, 1, 2, 3)]
      [int]$Verbosity = 0,
      [switch]$NoPerfData
   );

   $ServicesPackage      = New-IcingaCheckPackage -Name 'Services' -OperatorAnd -Verbose $Verbosity;
   $ServicesCountPackage = New-IcingaCheckPackage -Name 'Count Services' -OperatorAnd -Verbose $Verbosity -Hidden;

      [int]$StoppedCount,[int]$StartPendingCount,[int]$StopPendingCount,[int]$RunningCount,[int]$ContinuePendingCount,[int]$PausePendingCount,[int]$PausedCount,[int]$ServicesCounted = 0
      foreach ($services in $Service) {
         $IcingaCheck = $null;

         $FoundService    = Get-IcingaServices -Service $services;
         $ServiceName     = Get-IcingaServiceCheckName -ServiceInput $services -Service $FoundService;
         $ConvertedStatus = ConvertTo-ServiceStatusCode -Status $Status;
         $StatusRaw       = $FoundService.Values.configuration.Status.raw;

         $IcingaCheck = New-IcingaCheck -Name $ServiceName -Value $StatusRaw -ObjectExists $FoundService -Translation $ProviderEnums.ServiceStatusName;
         $IcingaCheck.CritIfNotMatch($ConvertedStatus) | Out-Null;
         $ServicesPackage.AddCheck($IcingaCheck)

         switch($StatusRaw) {
            {1 -contains $_} { $StoppedCount++;         $ServicesCounted++}
            {2 -contains $_} { $StartPendingCount++;    $ServicesCounted++}
            {3 -contains $_} { $StopPendingCount++;     $ServicesCounted++}
            {4 -contains $_} { $RunningCount++;         $ServicesCounted++}
            {5 -contains $_} { $ContinuePendingCount++; $ServicesCounted++}
            {6 -contains $_} { $PausePendingCount++;    $ServicesCounted++}
            {7 -contains $_} { $PausedCount++;          $ServicesCounted++}
         }
      }
   $IcingaStopped         = New-IcingaCheck -Name 'stopped services'           -Value $StoppedCount;
   $IcingaStartPending    = New-IcingaCheck -Name 'pending started services'   -Value $StartPendingCount;
   $IcingaStopPending     = New-IcingaCheck -Name 'pending stopped services'   -Value $StopPendingCount;
   $IcingaRunning         = New-IcingaCheck -Name 'running services'           -Value $RunningCount;
   $IcingaContinuePending = New-IcingaCheck -Name 'pending continued services' -Value $ContinuePendingCount;
   $IcingaPausePending    = New-IcingaCheck -Name 'pending paused services'    -Value $PausePendingCount;
   $IcingaPaused          = New-IcingaCheck -Name 'paused services'            -Value $PausePendingCount;
   
   $IcingaCount           = New-IcingaCheck -Name 'service count'              -Value $ServicesCounted;

   $ServicesCountPackage.AddCheck($IcingaStopped)
   $ServicesCountPackage.AddCheck($IcingaStartPending)
   $ServicesCountPackage.AddCheck($IcingaStopPending)
   $ServicesCountPackage.AddCheck($IcingaRunning)
   $ServicesCountPackage.AddCheck($IcingaContinuePending)
   $ServicesCountPackage.AddCheck($IcingaPausePending)
   $ServicesCountPackage.AddCheck($IcingaPaused)

   $ServicesCountPackage.AddCheck($IcingaCount)
   $ServicesPackage.AddCheck($ServicesCountPackage)

   return (New-IcingaCheckResult -Name 'Services' -Check $ServicesPackage -NoPerfData $NoPerfData -Compile);
}
