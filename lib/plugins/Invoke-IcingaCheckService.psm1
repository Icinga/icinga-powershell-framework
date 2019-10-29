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
      [string]$Status,
      [ValidateSet(0, 1, 2, 3)]
      [int]$Verbosity = 0
   );

   $ServicesPackage  = New-IcingaCheckPackage -Name 'Services' -OperatorAnd -Verbose $Verbosity;

   if ($Service.Count -ne 1) {
      foreach ($services in $Service) {
         $IcingaCheck = $null;

         $FoundService    = Get-IcingaServices -Service $services;
         $ServiceName     = Get-IcingaServiceCheckName -ServiceInput $services -Service $FoundService;
         $ConvertedStatus = ConvertTo-ServiceStatusCode -Status $Status;
         $StatusRaw       = $FoundService.Values.configuration.Status.raw;
      
         $IcingaCheck = New-IcingaCheck -Name $ServiceName -Value $StatusRaw -ObjectExists $FoundService -Translation $ProviderEnums.ServiceStatusName;
         $IcingaCheck.CritIfNotMatch($ConvertedStatus) | Out-Null;
         $ServicesPackage.AddCheck($IcingaCheck)
      }
   } else {

   $FoundService = Get-IcingaServices -Service $Service;
   $ServiceName  = Get-IcingaServiceCheckName -ServiceInput $Service -Service $FoundService;
   $Status       = ConvertTo-ServiceStatusCode -Status $Status;
   $StatusRaw    = $FoundService.Values.configuration.Status.raw;

   $IcingaCheck = New-IcingaCheck -Name $ServiceName -Value $StatusRaw -ObjectExists $FoundService -Translation $ProviderEnums.ServiceStatusName;
   $IcingaCheck.CritIfNotMatch($Status) | Out-Null;
   $ServicesPackage.AddCheck($IcingaCheck);

   }
   return (New-IcingaCheckResult -Name 'Services' -Check $ServicesPackage -NoPerfData $TRUE -Compile);
}
