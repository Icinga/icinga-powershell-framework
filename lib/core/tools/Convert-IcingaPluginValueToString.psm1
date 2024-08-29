<#
.SYNOPSIS
    Converts an Icinga plugin value to a human-readable string.

.DESCRIPTION
    The Convert-IcingaPluginValueToString function is used to convert an Icinga plugin value to a human-readable string. It supports various units and can handle percentage values.

.PARAMETER Value
    The value to be converted.

.PARAMETER BaseValue
    The base value used for percentage calculations.

.PARAMETER Unit
    The unit of the value.

.PARAMETER OriginalUnit
    The original unit of the value.

.PARAMETER UsePercent
    Specifies whether to treat the value as a percentage.

.PARAMETER IsThreshold
    Specifies whether the value is a threshold.

.OUTPUTS
    System.String
    Returns the converted value as a human-readable string.

.EXAMPLE
    Convert-IcingaPluginValueToString -Value 1024 -Unit 'KiB'
    Converts the value 1024 with the unit 'KiB' to a human-readable string.

.EXAMPLE
    Convert-IcingaPluginValueToString -Value 50 -BaseValue 100 -UsePercent
    Converts the value 50 as a percentage of the base value 100 to a human-readable string.

.NOTES
    This function is part of the Icinga PowerShell Framework module.
#>
function Convert-IcingaPluginValueToString()
{
    param (
        $Value                = $null,
        $BaseValue            = $null,
        [string]$Unit         = '',
        [string]$OriginalUnit = '',
        [switch]$UsePercent   = $FALSE,
        [switch]$IsThreshold  = $FALSE
    );

    $AdjustedValue      = $Value;
    $PercentValue       = $null;
    $HumanReadableValue = $null;

    if ([string]::IsNullOrEmpty($OriginalUnit)) {
        $OriginalUnit = $Unit;
    }

    try {
        $AdjustedValue = ([math]::Round([decimal]$Value, 6))
    } catch {
        $AdjustedValue = $Value;
    }

    if ($UsePercent -And ($null -eq $BaseValue -Or $BaseValue -eq 0)) {
        return ([string]::Format('{0}{1}', ([string]$AdjustedValue).Replace(',', '.'), $Unit));
    } elseif ($UsePercent) {
        $Unit = $OriginalUnit;
        if ($IsThreshold) {
            $PercentValue  = [math]::Round($Value, 2);
            $AdjustedValue = [math]::Round(($BaseValue / 100) * $Value, 2);
        } else {
            $PercentValue = [math]::Round(($Value / $BaseValue) * 100, 2);
        }
    }

    switch ($OriginalUnit) {
        { ($_ -eq "Kbit") -or ($_ -eq "Mbit") -or ($_ -eq "Gbit") -or ($_ -eq "Tbit") -or ($_ -eq "Pbit") -or ($_ -eq "Ebit") -or ($_ -eq "Zbit") -or ($_ -eq "Ybit") } {
            $TransferSpeed = Get-IcingaNetworkInterfaceUnits -Value $AdjustedValue -Unit $Unit;
            $HumanReadableValue = ([string]::Format('{0}{1}', $TransferSpeed.LinkSpeed, $TransferSpeed.Unit)).Replace(',', '.');
            break;
        };
        { ($_ -eq "B") -or ($_ -eq "KiB") -or ($_ -eq "MiB") -or ($_ -eq "GiB") -or ($_ -eq "TiB") -or ($_ -eq "PiB") -or ($_ -eq "EiB") -or ($_ -eq "ZiB") -or ($_ -eq "YiB") } {
            $HumanReadableValue = (ConvertTo-BytesNextUnit -Value $AdjustedValue -Unit $Unit -Units @('B', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB', 'EiB', 'ZiB', 'YiB')).Replace(',', '.');
            break;
        };
        { ($_ -eq "KB") -or ($_ -eq "MB") -or ($_ -eq "GB") -or ($_ -eq "TB") -or ($_ -eq "PB") -or ($_ -eq "EB") -or ($_ -eq "ZB") -or ($_ -eq "YB") } {
            $HumanReadableValue = (ConvertTo-BytesNextUnit -Value $AdjustedValue -Unit $Unit -Units @('B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB')).Replace(',', '.');
            break;
        };
        's' {
            $HumanReadableValue = (ConvertFrom-TimeSpan -Seconds $AdjustedValue).Replace(',', '.');
            break;
        };
    }

    if ($null -eq $HumanReadableValue) {
        $HumanReadableValue = ([string]::Format('{0}{1}', ([string]$AdjustedValue).Replace(',', '.'), $Unit));
    }

    # In case the value provided is a percentage value, we need to adjust the output so it doesn't make sense to add the percentage value again for this case
    if ($UsePercent -And $Unit -ne '%') {
        $HumanReadableValue = [string]::Format('{0} ({1}%)', $HumanReadableValue, $PercentValue);
    }

    return $HumanReadableValue;
}
