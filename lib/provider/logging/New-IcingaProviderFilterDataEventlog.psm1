<#
.ROLE
    Query
#>

function New-IcingaProviderFilterDataEventlog()
{
    param(
        [string]$LogName          = '',
        [array]$IncludeEventId    = @(),
        [array]$ExcludeEventId    = @(),
        [array]$IncludeUsername   = @(),
        [array]$ExcludeUsername   = @(),
        [array]$IncludeEntryType  = @(),
        [array]$ExcludeEntryType  = @(),
        [array]$IncludeMessage    = @(),
        [array]$ExcludeMessage    = @(),
        [array]$IncludeSource     = @(),
        [array]$ExcludeSource     = @(),
        [string]$EventsAfter      = $null,
        [string]$EventsBefore     = $null,
        [int]$MaxEntries          = 40000,
        [switch]$DisableTimeCache = $FALSE
    );

    [string]$EventLogFilter = '';
    $EventIdFilter          = New-Object -TypeName 'System.Text.StringBuilder';
    $EntryTypeFilter        = New-Object -TypeName 'System.Text.StringBuilder';
    $SourceFilter           = New-Object -TypeName 'System.Text.StringBuilder';
    $UserFilter             = New-Object -TypeName 'System.Text.StringBuilder';
    $TimeFilter             = New-Object -TypeName 'System.Text.StringBuilder';
    $EventAfterFilter       = $null;
    $EventBeforeFilter      = $null;
    $EventsAfter            = (Convert-IcingaPluginThresholds -Threshold $EventsAfter).Value;
    $EventsBefore           = (Convert-IcingaPluginThresholds -Threshold $EventsBefore).Value;
    [string]$CheckHash      = (Get-StringSha1 ($LogName + $IncludeEventId + $ExcludeEventId + $IncludeUsername + $ExcludeUsername + $IncludeEntryType + $ExcludeEntryType + $IncludeMessage + $ExcludeMessage)) + '.lastcheck';

    if ([string]::IsNullOrEmpty($EventsAfter) -and $DisableTimeCache -eq $FALSE) {
        $time = Get-IcingaCacheData -Space 'provider' -CacheStore 'eventlog' -KeyName $CheckHash;
        Set-IcingaCacheData -Space 'provider' -CacheStore 'eventlog' -KeyName $CheckHash -Value ((Get-Date).ToFileTime());

        if ($null -ne $time) {
            $EventAfterFilter = ([datetime]::FromFileTime($time)).ToString("yyyy-MM-dd HH:mm:ss");
        }
    }

    # In case we are not having cached time execution and not have not overwritten the timestamp, only fetch values from 2 hours in the past
    if ([string]::IsNullOrEmpty($EventAfterFilter)) {
        if ([string]::IsNullOrEmpty($EventsAfter)) {
            [string]$EventAfterFilter = ([datetime]::Now.Subtract([TimeSpan]::FromHours(2))).ToString("yyyy-MM-dd HH:mm:ss");
        } else {
            if ((Test-Numeric $EventsAfter)) {
                [string]$EventAfterFilter = ([datetime]::Now.Subtract([TimeSpan]::FromSeconds($EventsAfter))).ToString('yyyy\/MM\/dd HH:mm:ss');
            } else {
                [string]$EventAfterFilter = $EventsAfter;
            }
        }
    }

    if ([string]::IsNullOrEmpty($EventsBefore) -eq $FALSE) {
        if ((Test-Numeric $EventsBefore)) {
            [string]$EventBeforeFilter = ([datetime]::Now.Subtract([TimeSpan]::FromSeconds($EventsBefore))).ToString("yyyy-MM-dd HH:mm:ss");
        } else {
            [string]$EventBeforeFilter = $EventsBefore;
        }
    } else {
        [string]$EventBeforeFilter = ([datetime]::FromFileTime(((Get-Date).ToFileTime()))).ToString("yyyy-MM-dd HH:mm:ss");
    }

    foreach ($entry in $IncludeEventId) {
        if ($EventIdFilter.Length -ne 0) {
            $EventIdFilter.Append(
                ([string]::Format(' and EventID={0}', $entry))
            ) | Out-Null;
        } else {
            $EventIdFilter.Append(
                ([string]::Format('EventID={0}', $entry))
            ) | Out-Null;
        }
    }

    foreach ($entry in $ExcludeEventId) {
        if ($EventIdFilter.Length -ne 0) {
            $EventIdFilter.Append(
                ([string]::Format(' and EventID!={0}', $entry))
            ) | Out-Null;
        } else {
            $EventIdFilter.Append(
                ([string]::Format('EventID!={0}', $entry))
            ) | Out-Null;
        }
    }

    foreach ($entry in $IncludeEntryType) {
        [string]$EntryId = $ProviderEnums.EventLogSeverity[$entry];
        if ($EntryTypeFilter.Length -ne 0) {
            $EntryTypeFilter.Append(
                ([string]::Format(' and Level={0}', $EntryId))
            ) | Out-Null;
        } else {
            $EntryTypeFilter.Append(
                ([string]::Format('Level={0}', $EntryId))
            ) | Out-Null;
        }
    }

    foreach ($entry in $ExcludeEntryType) {
        [string]$EntryId = $ProviderEnums.EventLogSeverity[$entry];
        if ($EntryTypeFilter.Length -ne 0) {
            $EntryTypeFilter.Append(
                ([string]::Format(' and Level!={0}', $EntryId))
            ) | Out-Null;
        } else {
            $EntryTypeFilter.Append(
                ([string]::Format('Level!={0}', $EntryId))
            ) | Out-Null;
        }
    }

    foreach ($entry in $IncludeSource) {
        if ($SourceFilter.Length -ne 0) {
            $SourceFilter.Append(
                ([string]::Format(' and Provider[@Name="{0}"]', $entry))
            ) | Out-Null;
        } else {
            $SourceFilter.Append(
                ([string]::Format('Provider[@Name="{0}"]', $entry))
            ) | Out-Null;
        }
    }

    foreach ($entry in $ExcludeSource) {
        if ($SourceFilter.Length -ne 0) {
            $SourceFilter.Append(
                ([string]::Format(' and Provider[@Name!="{0}"]', $entry))
            ) | Out-Null;
        } else {
            $SourceFilter.Append(
                ([string]::Format('Provider[@Name!="{0}"]', $entry))
            ) | Out-Null;
        }
    }

    foreach ($entry in $IncludeUsername) {
        [string]$UserSID = (Get-IcingaUserSID -User $entry);
        if ($UserFilter.Length -ne 0) {
            $UserFilter.Append(
                ([string]::Format(' and Security[@UserID="{0}', $UserSID))
            ) | Out-Null;
        } else {
            $UserFilter.Append(
                ([string]::Format('Security[@UserID="{0}"]', $UserSID))
            ) | Out-Null;
        }
    }

    foreach ($entry in $ExcludeUsername) {
        [string]$UserSID = (Get-IcingaUserSID -User $entry);
        if ($UserFilter.Length -ne 0) {
            $UserFilter.Append(
                ([string]::Format(' and Security[@UserID!="{0}"]', $UserSID))
            ) | Out-Null;
        } else {
            $UserFilter.Append(
                ([string]::Format('Security[@UserID!="{0}"]', $UserSID))
            ) | Out-Null;
        }
    }

    $TimeFilter.Append(
        ([string]::Format('TimeCreated[@SystemTime>="{0}"]', (Get-Date $EventAfterFilter).ToUniversalTime().ToString("yyyy-MM-dd'T'HH:mm:ssZ")))
    ) | Out-Null;

    $TimeFilter.Append(
        ([string]::Format(' and TimeCreated[@SystemTime<="{0}"]', (Get-Date $EventBeforeFilter).ToUniversalTime().ToString("yyyy-MM-dd'T'HH:mm:ssZ")))
    ) | Out-Null;

    [string]$EventLogFilter = Add-IcingaProviderEventlogFilterData -EventFilter $EventLogFilter -StringBuilderObject $EventIdFilter;
    [string]$EventLogFilter = Add-IcingaProviderEventlogFilterData -EventFilter $EventLogFilter -StringBuilderObject $EntryTypeFilter;
    [string]$EventLogFilter = Add-IcingaProviderEventlogFilterData -EventFilter $EventLogFilter -StringBuilderObject $SourceFilter;
    [string]$EventLogFilter = Add-IcingaProviderEventlogFilterData -EventFilter $EventLogFilter -StringBuilderObject $UserFilter;
    [string]$EventLogFilter = Add-IcingaProviderEventlogFilterData -EventFilter $EventLogFilter -StringBuilderObject $TimeFilter;

    while ($EventLogFilter[0] -eq ' ') {
        $EventLogFilter = $EventLogFilter.Substring(1, $EventLogFilter.Length - 1);
    }

    [string]$EventLogFilter = [string]::Format('Event[System[{0}]]', $EventLogFilter);

    try {
        $EventLogEntries = Get-WinEvent -LogName $LogName -MaxEvents $MaxEntries -FilterXPath $EventLogFilter -ErrorAction Stop;
    } catch {
        Exit-IcingaThrowException -InputString $_.FullyQualifiedErrorId -StringPattern 'ParameterArgumentValidationError' -ExceptionList $IcingaPluginExceptions -ExceptionType 'Input' -ExceptionThrown $IcingaPluginExceptions.Inputs.EventLogNegativeEntries;
        Exit-IcingaThrowException -InputString $_.FullyQualifiedErrorId -StringPattern 'CannotConvertArgumentNoMessage' -ExceptionList $IcingaPluginExceptions -ExceptionType 'Input' -ExceptionThrown $IcingaPluginExceptions.Inputs.EventLogNoMessageEntries;
        Exit-IcingaThrowException -InputString $_.FullyQualifiedErrorId -StringPattern 'NoMatchingLogsFound' -CustomMessage (-Join $LogName) -ExceptionList $IcingaPluginExceptions -ExceptionType 'Input' -ExceptionThrown $IcingaPluginExceptions.Inputs.EventLogLogName;
    }

    $EventLogQueryData = New-Object PSCustomObject;
    $EventLogQueryData | Add-Member -MemberType NoteProperty -Name 'List'      -Value (New-Object PSCustomObject);
    $EventLogQueryData | Add-Member -MemberType NoteProperty -Name 'Events'    -Value (New-Object PSCustomObject);
    $EventLogQueryData | Add-Member -MemberType NoteProperty -Name 'HasEvents' -Value $FALSE;

    foreach ($event in $EventLogEntries) {
        # Filter out remaining message not matching our filter
        if ((Test-IcingaArrayFilter -InputObject $event.Message -Include $IncludeMessage -Exclude $ExcludeMessage) -eq $FALSE) {
            continue;
        }

        $EventLogQueryData.HasEvents = $TRUE;

        [string]$EventIdentifier = [string]::Format('{0}-{1}',
            $event.Id,
            $event.ProviderName
        );

        [string]$EventHash = Get-StringSha1 $EventIdentifier;

        if ((Test-PSCustomObjectMember -PSObject $EventLogQueryData.List -Name $EventHash) -eq $FALSE) {
            [string]$EventMessage = [string]($event.Message);
            if ([string]::IsNullOrEmpty($EventMessage)) {
                $EventMessage = '';
            }

            $EventLogQueryData.List            | Add-Member -MemberType NoteProperty -Name $EventHash    -Value (New-Object PSCustomObject);
            $EventLogQueryData.List.$EventHash | Add-Member -MemberType NoteProperty -Name 'NewestEntry' -Value ([string]($event.TimeCreated));
            $EventLogQueryData.List.$EventHash | Add-Member -MemberType NoteProperty -Name 'OldestEntry' -Value ([string]($event.TimeCreated));
            $EventLogQueryData.List.$EventHash | Add-Member -MemberType NoteProperty -Name 'EventId'     -Value ([string]($event.Id));
            $EventLogQueryData.List.$EventHash | Add-Member -MemberType NoteProperty -Name 'Message'     -Value $EventMessage;
            $EventLogQueryData.List.$EventHash | Add-Member -MemberType NoteProperty -Name 'Severity'    -Value $ProviderEnums.EventLogSeverityName[$event.Level];
            $EventLogQueryData.List.$EventHash | Add-Member -MemberType NoteProperty -Name 'Source'      -Value ([string]($event.ProviderName));
            $EventLogQueryData.List.$EventHash | Add-Member -MemberType NoteProperty -Name 'Count'       -Value 1;

        } else {
            $EventLogQueryData.List.$EventHash.OldestEntry  = ([string]($event.TimeCreated));
            $EventLogQueryData.List.$EventHash.Count       += 1;
        }

        if ((Test-PSCustomObjectMember -PSObject $EventLogQueryData.Events -Name $event.Id) -eq $FALSE) {
            $EventLogQueryData.Events | Add-Member -MemberType NoteProperty -Name $event.Id -Value 1;
        } else {
            $EventLogQueryData.Events.($event.Id) += 1;
        }
    }

    if ($null -ne $EventLogEntries) {
        $EventLogEntries.Dispose();
    }

    $EventLogEntries = $null;
    $EventLogFilter  = $null;
    $EventIdFilter   = $null;
    $EntryTypeFilter = $null;
    $SourceFilter    = $null;
    $UserFilter      = $null;
    $TimeFilter      = $null;

    return $EventLogQueryData;
}
