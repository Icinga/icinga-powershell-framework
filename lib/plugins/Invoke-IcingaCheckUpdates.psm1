Import-IcingaLib icinga\plugin;
Import-IcingaLib provider\updates;

function Invoke-IcingaCheckUpdates()
{
    param (
        [array]$UpdateFilter,
        $Warning,
        $Critical,
        [switch]$NoPerfData,
        [int]$Verbose
    );

    $PendingUpdates = Get-IcingaUpdatesPending;
    
    $UpdateCount    = New-IcingaCheckPackage -Name 'Pending Update Count' -OperatorAnd;
    $UpdateList     = New-IcingaCheckPackage -Name 'Update List' -OperatorAnd;
    $PendingCount   = 0;

    if ($UpdateFilter.Count -ne 0) {
        foreach ($Filter in $UpdateFilter) {
            foreach ($Update in $PendingUpdates.updates.Keys) {
                if ($Update -Like $Filter) {
                    $PendingCount += 1;
                    $UpdateList.AddCheck(
                        (New-IcingaCheck -Name $Update -Value 'pending' -NoPerfData)
                    );
                }
            }
        }
        if ($PendingCount -eq 0) {
            $UpdateList.AddCheck(
                (New-IcingaCheck -Name 'No update' -Value 'pending' -NoPerfData)
            );
        }
    } else {
        $PendingCount = $PendingUpdates.count;
        foreach ($Update in $PendingUpdates.updates.Keys) {
            $UpdateList.AddCheck(
                (New-IcingaCheck -Name $Update -Value 'pending' -NoPerfData)
            );
        }
    }

    $IcingaCheck = New-IcingaCheck -Name 'Pending Update Count' -Value $PendingCount;
    $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
    $UpdateCount.AddCheck($IcingaCheck);

    $UpdatePackage  = New-IcingaCheckPackage -Name 'Updates' -OperatorAnd -Verbose $Verbose -Checks @(
        $UpdateCount, $UpdateList
    );

    exit (New-IcingaCheckResult -Name 'Pending Updates' -Check $UpdatePackage -NoPerfData $NoPerfData -Compile);
}
