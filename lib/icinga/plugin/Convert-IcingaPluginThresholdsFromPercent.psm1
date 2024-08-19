<#
.SYNOPSIS
    Converts Icinga plugin thresholds from percentage to actual values.

.DESCRIPTION
    The Convert-IcingaPluginThresholdsFromPercent function takes a base value and a threshold object and converts the threshold values from percentage to actual values. It supports various threshold modes such as Default, Lower, LowerEqual, Greater, GreaterEqual, Between, Outside, Matches, and NotMatches.

.PARAMETER BaseValue
    The base value used for calculating the threshold values.

.PARAMETER Threshold
    The threshold object containing the threshold mode and value.

.OUTPUTS
    The modified threshold object with the converted threshold values.

.EXAMPLE
    $baseValue = 274112400000
    $threshold = @{
        EndRange   = 90;
        Unit       = '%';
        StartRange = 30;
        Threshold  = '@30:90';
        Mode       = 6;
        Raw        = '@30%:90%';
        IsDateTime = $FALSE;
        Value      = $null;
    }

    Convert-IcingaPluginThresholdsFromPercent -BaseValue $baseValue -Threshold $threshold

    This example converts the threshold value of 50% to the actual value based on the provided base value of 100.

.NOTES

#>
function Convert-IcingaPluginThresholdsFromPercent()
{
    param (
        $BaseValue  = $null,
        $Threshold  = $null
    );

    if ($null -eq $Threshold -Or $null -eq $BaseValue -Or $BaseValue -eq 0) {
        return $Threshold;
    }

    switch ($Threshold.Mode) {
        $IcingaEnums.IcingaThresholdMethod.Default {
            $Threshold.Threshold = [math]::Round($BaseValue / 100 * $Threshold.Value, 0);
            break;
        };
        $IcingaEnums.IcingaThresholdMethod.Lower {
            $Threshold.Threshold = [math]::Round($BaseValue / 100 * $Threshold.Value, 0);
            break;
        };
        $IcingaEnums.IcingaThresholdMethod.LowerEqual {
            $Threshold.Threshold = [math]::Round($BaseValue / 100 * $Threshold.Value, 0);
            break;
        };
        $IcingaEnums.IcingaThresholdMethod.Greater {
            $Threshold.Threshold = [math]::Round($BaseValue / 100 * $Threshold.Value, 0);
            break;
        };
        $IcingaEnums.IcingaThresholdMethod.GreaterEqual {
            $Threshold.Threshold = [math]::Round($BaseValue / 100 * $Threshold.Value, 0);
            break;
        };
        $IcingaEnums.IcingaThresholdMethod.Between {
            $StartRange = [math]::Round($BaseValue / 100 * $Threshold.StartRange, 0);
            $EndRange   = [math]::Round($BaseValue / 100 * $Threshold.EndRange, 0);

            $Threshold.Threshold = [string]::Format('{0}:{1}', $StartRange, $EndRange);
            break;
        };
        $IcingaEnums.IcingaThresholdMethod.Outside {
            $StartRange = [math]::Round($BaseValue / 100 * $Threshold.StartRange, 0);
            $EndRange   = [math]::Round($BaseValue / 100 * $Threshold.EndRange, 0);

            $Threshold.Threshold = [string]::Format('@{0}:{1}', $StartRange, $EndRange);
            break;
        };
        $IcingaEnums.IcingaThresholdMethod.Matches {
            break;
        };
        $IcingaEnums.IcingaThresholdMethod.NotMatches {
            break;
        };
    }

    return $Threshold;
}
