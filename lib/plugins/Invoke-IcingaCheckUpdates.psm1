Import-IcingaLib icinga\plugin;
Import-IcingaLib provider\updates;

<#
.SYNOPSIS
   Checks how many updates are to be applied
.DESCRIPTION
   Invoke-IcingaCheckUpdates returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
   e.g 'C:\Users\Icinga\Backup' 10 updates are pending, WARNING is set to 20, CRITICAL is set to 50. In this case the check will return OK.
   More Information on https://github.com/Icinga/icinga-powershell-framework
.FUNCTIONALITY
   This module is intended to be used to check how many updates are to be applied and thereby currently pending
   Based on the thresholds set the status will change between 'OK', 'WARNING' or 'CRITICAL'. The function will return one of these given codes.
   
.EXAMPLE
   PS> Invoke-IcingaCheckUpdates -Warning 4 -Critical 20
   [OK]: Check package "Updates" is [OK]
   | 'Pending Update Count'=2;4;20 
.PARAMETER Warning
   Used to specify a Warning threshold. In this case an integer value.
.PARAMETER Critical
   Used to specify a Critical threshold. In this case an integer value.
.INPUTS
   System.String
.OUTPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function Invoke-IcingaCheckUpdates()
{
    param (
        [array]$UpdateFilter,
        $Warning             = $null,
        $Critical            = $null,
        [switch]$NoPerfData,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity      = 0
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

    $UpdatePackage  = New-IcingaCheckPackage -Name 'Windows Updates' -OperatorAnd -Verbose $Verbosity -Checks @(
        $UpdateCount
    );

    if ($PendingCount -ne 0) {
        $UpdatePackage.AddCheck($UpdateList);
    }

    return (New-IcingaCheckResult -Name 'Pending Updates' -Check $UpdatePackage -NoPerfData $NoPerfData -Compile);
}
