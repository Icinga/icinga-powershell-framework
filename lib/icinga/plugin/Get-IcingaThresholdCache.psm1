function Get-IcingaThresholdCache()
{
    param (
        [string]$CheckCommand = $null
    );

    if ([string]::IsNullOrEmpty($CheckCommand)) {
        return $null;
    }

    if ($Global:Icinga.Private.Scheduler.ThresholdCache.ContainsKey($CheckCommand) -eq $FALSE) {
        return $null;
    }

    return $Global:Icinga.Private.Scheduler.ThresholdCache[$CheckCommand];
}
