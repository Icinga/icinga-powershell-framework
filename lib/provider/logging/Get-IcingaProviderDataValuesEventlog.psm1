function Get-IcingaProviderDataValuesEventlog()
{
    param (
        [array]$IncludeFilter      = @(),
        [array]$ExcludeFilter      = @(),
        [hashtable]$ProviderFilter = @{ },
        [switch]$IncludeDetails    = $FALSE
    );

    $EventlogData            = New-IcingaProviderObject -Name 'Eventlog';
    [hashtable]$FilterObject = Get-IcingaProviderFilterData -ProviderName 'Eventlog' -ProviderFilter $ProviderFilter;

    $EventLogData.Metrics | Add-Member -MemberType NoteProperty -Name 'List'      -Value $FilterObject.EventLog.Query.List;
    $EventLogData.Metrics | Add-Member -MemberType NoteProperty -Name 'Events'    -Value $FilterObject.EventLog.Query.Events;
    $EventLogData.Metrics | Add-Member -MemberType NoteProperty -Name 'Problems'  -Value $FilterObject.EventLog.Query.Problems;
    $EventLogData.Metrics | Add-Member -MemberType NoteProperty -Name 'HasEvents' -Value $FilterObject.EventLog.Query.HasEvents;

    $FilterObject = $null;

    return $EventlogData;
}
