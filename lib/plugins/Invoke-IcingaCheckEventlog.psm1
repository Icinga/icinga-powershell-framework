Import-IcingaLib icinga\plugin;

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
        $After = $null,
        $Before = $null,
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
