Import-IcingaLib icinga\plugin;

<#
.SYNOPSIS
   Checks how many eventlog occurences of a given type there are.
.DESCRIPTION
   Invoke-IcingaCheckEventlog returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
   e.g Eventlog returns 500 entrys with the specified parameters, WARNING is set to 200, CRITICAL is set to 800. Thereby the check will return WARNING.

   More Information on https://github.com/Icinga/icinga-powershell-framework
.FUNCTIONALITY
   This Module is intended to be used to check how many eventlog occurences of a given type there are.
   Based on the thresholds set the status will change between 'OK', 'WARNING' or 'CRITICAL'. The function will return one of these given codes.
.EXAMPLE
   PS> Invoke-IcingaCheckEventlog -LogName Application -IncludeEntryType Warning -Warning 100 -Critical 1000
   [WARNING]: Check package "EventLog" is [WARNING]
   | 'EventId_508'=2c;; 'EventId_2002'=586c;; 'EventId_63'=6c;; 'EventId_2248216578'=1364c;; 'EventId_1008'=1745c;; 'EventId_2147489653'=1c;; 'EventId_636'=3c;; 'EventId_2147484656'=1c;; 'EventId_2147489654'=1c;; 'EventId_640'=3c;; 'EventId_533'=1c;;
   1
   PS> Invoke-IcingaCheckEventlog -LogName Application -IncludeEntryType Warning -Warning 100 -Critical 1000
   [OK]: Check package "EventLog" is [OK]|
   0
.EXAMPLE
   PS> Invoke-IcingaCheckEventlog -LogName Application -IncludeEntryType Warning -Warning 100 -Critical 1000
   [WARNING]: Check package "EventLog" is [WARNING]
   | 'EventId_508'=2c;; 'EventId_2002'=586c;; 'EventId_63'=6c;; 'EventId_2248216578'=1364c;; 'EventId_1008'=1745c;; 'EventId_2147489653'=1c;; 'EventId_636'=3c;; 'EventId_2147484656'=1c;; 'EventId_2147489654'=1c;; 'EventId_640'=3c;; 'EventId_533'=1c;;
   1
   PS> Invoke-IcingaCheckEventlog -LogName Application -IncludeEntryType Warning -Warning 100 -Critical 1000 -DisableTimeCache
   [WARNING]: Check package "EventLog" is [WARNING]
   | 'EventId_508'=2c;; 'EventId_2002'=586c;; 'EventId_63'=6c;; 'EventId_2248216578'=1364c;; 'EventId_1008'=1745c;; 'EventId_2147489653'=1c;; 'EventId_636'=3c;; 'EventId_2147484656'=1c;; 'EventId_2147489654'=1c;; 'EventId_640'=3c;; 'EventId_533'=1c;;
   1
.PARAMETER Warning
   Used to specify a Warning threshold.
.PARAMETER Critical
   Used to specify a Critical threshold.
.PARAMETER LogName
   Used to specify a certain log.
.PARAMETER IncludeEventId
   Used to specify an array of events identified by their id to be included.
.PARAMETER ExcludeEventId
   Used to specify an array of events identified by their id to be excluded.
.PARAMETER IncludeUsername
   Used to specify an array of usernames within the eventlog to be included.
.PARAMETER ExcludeUsername
   Used to specify an array of usernames within the eventlog to be excluded.
.PARAMETER IncludeEntryType
   Used to specify an array of entry types within the eventlog to be included.
.PARAMETER ExcludeEntryType
   Used to specify an array of entry types within the eventlog to be excluded.
.PARAMETER IncludeMessage
   Used to specify an array of messages within the eventlog to be included.
.PARAMETER ExcludeMessage
   Used to specify an array of messages within the eventlog to be excluded.
.PARAMETER After
   Used to specify a date like dd.mm.yyyy and every eventlog entry after that date will be considered.
.PARAMETER Before
   Used to specify a date like dd.mm.yyyy and every eventlog entry before that date will be considered.
.PARAMETER DisableTimeCache
   Switch to disable the time cache on a check. If this parameter is set the time cache is disabled.
   After the check has been run once, the next check instance will filter through the eventlog from the point the last check ended.
   This is due to the time cache, when disabled the whole eventlog is checked instead.
.INPUTS
   System.String
.OUTPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function Invoke-IcingaCheckEventlog()
{
    param(
        $Warning                  = $null,
        $Critical                 = $null,
        [string]$LogName,
        [array]$IncludeEventId,
        [array]$ExcludeEventId,
        [array]$IncludeUsername,
        [array]$ExcludeUsername,
        [array]$IncludeEntryType,
        [array]$ExcludeEntryType,
        [array]$IncludeMessage,
        [array]$ExcludeMessage,
        $After                    = $null,
        $Before                   = $null,
        [switch]$DisableTimeCache = $FALSE,
        [switch]$NoPerfData,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity           = 0
    );

    $EventLogPackage = New-IcingaCheckPackage -Name 'EventLog' -OperatorAnd -Verbose $Verbosity;
    $EventLogData    = Get-IcingaEventLog -LogName $LogName -IncludeEventId $IncludeEventId -ExcludeEventId $ExcludeEventId -IncludeUsername $IncludeUsername -ExcludeUsername $ExcludeUsername `
                                       -IncludeEntryType $IncludeEntryType -ExcludeEntryType $ExcludeEntryType -IncludeMessage $IncludeMessage -ExcludeMessage $ExcludeMessage `
                                       -After $After -Before $Before -DisableTimeCache $DisableTimeCache;

    if ($EventLogData.eventlog.Count -ne 0) {
        foreach ($event in $EventLogData.eventlog.Keys) {
            $eventEntry = $EventLogData.eventlog[$event];
            $EventLogEntryPackage = New-IcingaCheckPackage -Name ([string]::Format('Between: [{0}] - [{1}] there occured {2} event(s).', $eventEntry.OldestEntry, $eventEntry.NewestEntry, $eventEntry.Count)) -OperatorAnd -Verbose $Verbosity;
            $IcingaCheck = New-IcingaCheck -Name ([string]::Format('EventId {0}', $EventLogData.eventlog[$event].EventId)) -Value $eventEntry.Count -NoPerfData;
            $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
            $EventLogEntryPackage.AddCheck($IcingaCheck);

            $EventLogPackage.AddCheck($EventLogEntryPackage);
        }

        $EventLogCountPackage = New-IcingaCheckPackage -Name 'EventLog Count' -OperatorAnd -Verbose $Verbosity -Hidden;

        foreach ($event in $EventLogData.events.Keys) {
            $IcingaCheck = New-IcingaCheck -Name ([string]::Format('EventId {0}', $event)) -Value $EventLogData.events[$event] -Unit 'c';
            $EventLogCountPackage.AddCheck($IcingaCheck);
        }

        $EventLogPackage.AddCheck($EventLogCountPackage);
    } else {
        $IcingaCheck = New-IcingaCheck -Name 'No EventLogs found' -Value 0 -Unit 'c' -NoPerfData;
        $EventLogPackage.AddCheck($IcingaCheck);
    }

    return (New-IcingaCheckResult -Name 'EventLog' -Check $EventLogPackage -NoPerfData $NoPerfData -Compile);
}
