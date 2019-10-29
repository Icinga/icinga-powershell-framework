Import-IcingaLib icinga\plugin;

<#
.SYNOPSIS
   ???
.DESCRIPTION
   ???
   e.g 

   More Information on https://github.com/LordHepipud/icinga-module-windows
.FUNCTIONALITY
   ???
   Based on the thresholds set the status will change between 'OK', 'WARNING' or 'CRITICAL'. The function will return one of these given codes.
.EXAMPLE
   PS>
.EXAMPLE
   PS>
.EXAMPLE
   PS>
.EXAMPLE
   PS>
.PARAMETER Warning
   Used to specify a Warning threshold. In this case an ??? value.
.PARAMETER Critical
   Used to specify a Critical threshold. In this case an ??? value.
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
   ???
.PARAMETER Before
   ???
.PARAMETER DisableTimeCache
   Switch to disable the time cache on a check. If this parameter is set the time cache is disabled.
.INPUTS
   System.String
.OUTPUTS
   System.String
.LINK
   https://github.com/LordHepipud/icinga-module-windows
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
