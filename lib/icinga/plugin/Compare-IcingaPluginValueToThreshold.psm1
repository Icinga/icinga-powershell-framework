<#
.SYNOPSIS
    Compares a value to a threshold and returns a result.

.DESCRIPTION
    The Compare-IcingaPluginValueToThreshold function compares a value to a threshold and returns a result indicating whether the value meets the threshold criteria. It supports various threshold methods such as default, lower, lower equal, greater, greater equal, between, outside, matches, and not matches. The function also handles percentage values and provides human-readable output.

.PARAMETER Value
    The value to compare against the threshold.

.PARAMETER BaseValue
    The base value used for percentage calculations.

.PARAMETER Unit
    The unit of measurement for the value.

.PARAMETER Translation
    The translation table for converting values to human-readable format.

.PARAMETER Threshold
    The threshold object containing the threshold criteria.

.PARAMETER OverrideMode
    The override mode for the threshold.

.OUTPUTS
    A hashtable containing the following properties:
    - Message: The result message indicating whether the value meets the threshold criteria.
    - IsOk: A boolean value indicating whether the value meets the threshold criteria.
    - HasError: A boolean value indicating whether an error occurred during the comparison.

.EXAMPLE
    $threshold = @{
        EndRange   = $null;
        Unit       = 'B';
        StartRange = $null;
        Threshold  = '30000000MB';
        Mode       = 0;
        Raw        = '30MB';
        IsDateTime = $FALSE;
        Value      = 30000000;
    }
    Compare-IcingaPluginValueToThreshold -Value 450000000 -Unit 'B' -Threshold $threshold

    This example compares the value 15 to the threshold criteria specified in the $threshold object. The function returns a hashtable with the result message, IsOk, and HasError properties.

.NOTES
    This function is part of the Icinga PowerShell Framework module.

.LINK
    https://github.com/icinga/icinga-powershell-framework

#>
function Compare-IcingaPluginValueToThreshold()
{
    param (
        $Value        = $null,
        $BaseValue    = $null,
        $Unit         = $null,
        $Translation  = $null,
        $Threshold    = $null,
        $OverrideMode = $null
    );

    [hashtable]$RetValue = @{
        'Message'  = '';
        'IsOk'     = $FALSE;
        'HasError' = $FALSE;
    }
    $HumanReadableValue = $Value;
    $PercentValue       = $null;
    $TranslatedValue    = $Value;
    [bool]$UsePercent   = $FALSE;

    # Otherwise just convert the values to human readble values
    $HumanReadableValue = ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value $HumanReadableValue;
    $HumanReadableValue = Convert-IcingaPluginValueToString -Value $HumanReadableValue -Unit $Unit;

    if ($null -eq $Value -Or $null -eq $Threshold -Or [string]::IsNullOrEmpty($Threshold.Raw)) {
        $RetValue.Message = $HumanReadableValue;
        $RetValue.IsOk    = $TRUE;

        return $RetValue;
    }

    if (Test-Numeric $Value) {
        [decimal]$Value = $Value;
    }

    if ($null -eq $OverrideMode) {
        $OverrideMode = $Threshold.Mode;
    }

    if ($Threshold.Unit -eq '%' -And $null -eq $BaseValue) {
        $RetValue.Message  = 'This plugin threshold does not support percentage units';
        $RetValue.HasError = $TRUE;

        return $RetValue;
    }

    # In case we have a percentage value, we need to adjust the value
    if ($Threshold.Unit -eq '%' -And $null -ne $BaseValue -And $BaseValue -ne 0) {
        $UsePercent         = $TRUE;
        $HumanReadableValue = Convert-IcingaPluginValueToString -Value $Value -BaseValue $BaseValue -Unit $Threshold.Unit -OriginalUnit $Unit -UsePercent:$UsePercent;
        $Value              = [math]::Round(($Value / $BaseValue) * 100, 2);
        # Ensure that we properly set the threshold range or metrics we defined from percent to acutal values based on the BaseValue
        # Otherwise performance metrics will not be properly reported, causing later issues for visualiation tools like Grafana
        $Threshold          = Convert-IcingaPluginThresholdsFromPercent -BaseValue $BaseValue -Threshold $Threshold;
    } else {
        $TranslatedValue = ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value $Value;
    }

    switch ($OverrideMode) {
        $IcingaEnums.IcingaThresholdMethod.Default {
            if ($Value -lt 0 -Or $Value -gt $Threshold.Value) {
                if ($Value -lt 0) {
                    $RetValue.Message = [string]::Format('Value {0} is lower than 0', $HumanReadableValue);
                    return $RetValue;
                }

                if ($Value -gt $Threshold.Value) {
                    $RetValue.Message = [string]::Format('Value {0} is greater than threshold {1}', $HumanReadableValue, (Convert-IcingaPluginValueToString -Value $Threshold.Value -BaseValue $BaseValue -Unit $Threshold.Unit -OriginalUnit $Unit -UsePercent:$UsePercent -IsThreshold));
                    return $RetValue;
                }
            }
            break;
        };
        $IcingaEnums.IcingaThresholdMethod.Lower {
            if ($Value -lt $Threshold.Value) {
                $RetValue.Message = [string]::Format('Value {0} is lower than threshold {1}', $HumanReadableValue, (Convert-IcingaPluginValueToString -Value $Threshold.Value -BaseValue $BaseValue -Unit $Threshold.Unit -OriginalUnit $Unit -UsePercent:$UsePercent -IsThreshold));
                return $RetValue;
            }
            break;
        };
        $IcingaEnums.IcingaThresholdMethod.LowerEqual {
            if ($Value -le $Threshold.Value) {
                $RetValue.Message = [string]::Format('Value {0} is lower or equal than threshold {1}', $HumanReadableValue, (Convert-IcingaPluginValueToString -Value $Threshold.Value -BaseValue $BaseValue -Unit $Threshold.Unit -OriginalUnit $Unit -UsePercent:$UsePercent -IsThreshold));
                return $RetValue;
            }
            break;
        };
        $IcingaEnums.IcingaThresholdMethod.Greater {
            if ($Value -gt $Threshold.Value) {
                $RetValue.Message = [string]::Format('Value {0} is greater than threshold {1}', $HumanReadableValue, (Convert-IcingaPluginValueToString -Value $Threshold.Value -BaseValue $BaseValue -Unit $Threshold.Unit -OriginalUnit $Unit -UsePercent:$UsePercent -IsThreshold));
                return $RetValue;
            }
            break;
        };
        $IcingaEnums.IcingaThresholdMethod.GreaterEqual {
            if ($Value -gt $Threshold.Value) {
                $RetValue.Message = [string]::Format('Value {0} is greater or equal than threshold {1}', $HumanReadableValue, (Convert-IcingaPluginValueToString -Value $Threshold.Value -BaseValue $BaseValue -Unit $Threshold.Unit -OriginalUnit $Unit -UsePercent:$UsePercent -IsThreshold));
                return $RetValue;
            }
            break;
        };
        $IcingaEnums.IcingaThresholdMethod.Between {
            if ($Value -lt $Threshold.StartRange -Or $Value -gt $Threshold.EndRange) {
                $RetValue.Message = [string]::Format('Value {0} is not between thresholds <{1} or >{2}', $HumanReadableValue, (Convert-IcingaPluginValueToString -Value $Threshold.StartRange -BaseValue $BaseValue -Unit $Threshold.Unit -OriginalUnit $Unit -UsePercent:$UsePercent -IsThreshold), (Convert-IcingaPluginValueToString -Value $Threshold.EndRange -BaseValue $BaseValue -Unit $Threshold.Unit -OriginalUnit $Unit -UsePercent:$UsePercent -IsThreshold));
                return $RetValue;
            }
            break;
        };
        $IcingaEnums.IcingaThresholdMethod.Outside {
            if ($Value -ge $Threshold.StartRange -And $Value -le $Threshold.EndRange) {
                $RetValue.Message = [string]::Format('Value {0} is between thresholds >={1} and <={2}', $HumanReadableValue, (Convert-IcingaPluginValueToString -Value $Threshold.StartRange -BaseValue $BaseValue -Unit $Threshold.Unit -OriginalUnit $Unit -UsePercent:$UsePercent -IsThreshold), (Convert-IcingaPluginValueToString -Value $Threshold.EndRange -BaseValue $BaseValue -Unit $Threshold.Unit -OriginalUnit $Unit -UsePercent:$UsePercent -IsThreshold));
                return $RetValue;
            }
            break;
        };
        $IcingaEnums.IcingaThresholdMethod.Matches {
            if ($Value -Like $Threshold.Value ) {
                $RetValue.Message = [string]::Format('Value {0} is matching threshold {1}', $TranslatedValue, (ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value $Threshold.Value));
                return $RetValue;
            }
            break;
        };
        $IcingaEnums.IcingaThresholdMethod.NotMatches {
            if ($Value -NotLike $Threshold.Value ) {
                $RetValue.Message = [string]::Format('Value {0} is not matching threshold {1}', $TranslatedValue, (ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value $Threshold.Value));
                return $RetValue;
            }
            break;
        };
    }

    $RetValue.Message = $HumanReadableValue;
    $RetValue.IsOk    = $TRUE;

    return $RetValue;
}
