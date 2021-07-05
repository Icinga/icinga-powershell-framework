function Get-IcingaThresholdCache()
{
    param (
        [string]$CheckCommand = $null
    );

    if ([string]::IsNullOrEmpty($CheckCommand)) {
        return $null;
    }

    if ($null -eq $Global:Icinga) {
        return $null;
    }

    if ($Global:Icinga.ContainsKey('ThresholdCache') -eq $FALSE) {
        return $null;
    }

    if ($Global:Icinga.ThresholdCache.ContainsKey($CheckCommand) -eq $FALSE) {
        return $null;
    }

    return $Global:Icinga.ThresholdCache[$CheckCommand];
}
