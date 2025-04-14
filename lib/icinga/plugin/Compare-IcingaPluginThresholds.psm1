<#
.SYNOPSIS
    Compares a value against specified thresholds and returns the result.

.DESCRIPTION
    The Compare-IcingaPluginThresholds function compares a given value against specified thresholds and returns an object containing the comparison result. It supports various comparison methods such as Matches, NotMatches, Between, LowerEqual, and GreaterEqual. If an error occurs during the comparison, the function returns an object with the error details.

.PARAMETER Threshold
    Specifies the threshold value or range to compare against. This can be a single value or a range specified in the format "min:max". If not provided, the function assumes no threshold.

.PARAMETER InputValue
    Specifies the value to compare against the threshold.

.PARAMETER BaseValue
    Specifies the base value for percentage calculations. If the unit is set to '%', the base value is used to calculate the percentage. If not provided, the function assumes no base value.

.PARAMETER Matches
    Indicates that the comparison should use the Matches method. This method checks if the input value matches the threshold.

.PARAMETER NotMatches
    Indicates that the comparison should use the NotMatches method. This method checks if the input value does not match the threshold.

.PARAMETER DateTime
    Specifies whether the input value is a DateTime object. If set to $true, the input value is treated as a DateTime object.

.PARAMETER Unit
    Specifies the unit of measurement for the values. This is used for percentage calculations. If not provided, the function assumes no unit.

.PARAMETER ThresholdCache
    Specifies a cache object to store threshold values for reuse.

.PARAMETER CheckName
    Specifies the name of the check being performed.

.PARAMETER PerfDataLabel
    Specifies the label for the performance data.

.PARAMETER Translation
    Specifies a hashtable for translating threshold values.

.PARAMETER Minium
    Specifies the minimum threshold value for comparison. This is used when the IsBetween method is used.

.PARAMETER Maximum
    Specifies the maximum threshold value for comparison. This is used when the IsBetween method is used.

.PARAMETER IsBetween
    Indicates that the comparison should use the IsBetween method. This method checks if the input value is between the minimum and maximum thresholds.

.PARAMETER IsLowerEqual
    Indicates that the comparison should use the IsLowerEqual method. This method checks if the input value is lower than or equal to the threshold.

.PARAMETER IsGreaterEqual
    Indicates that the comparison should use the IsGreaterEqual method. This method checks if the input value is greater than or equal to the threshold.

.PARAMETER TimeInterval
    Specifies the time interval for the comparison. This is used when the input value is a DateTime object.

.OUTPUTS
    The function returns an object containing the comparison result. The object has the following properties:
    - Value: The input value.
    - Unit: The unit of measurement.
    - Message: The result message of the comparison.
    - IsOK: Indicates whether the comparison result is OK.
    - HasError: Indicates whether an error occurred during the comparison.
    - Threshold: The threshold value or range used for comparison.
    - Minimum: The minimum threshold value used for comparison.
    - Maximum: The maximum threshold value used for comparison.

.EXAMPLE
    $threshold = "10:20"
    $inputValue = 15
    $baseValue = 100
    $result = Compare-IcingaPluginThresholds -Threshold $threshold -InputValue $inputValue -BaseValue $baseValue
    $result.IsOK
    # Returns $true

.NOTES
    This function is part of the Icinga PowerShell Framework module.
#>
function Compare-IcingaPluginThresholds()
{
    param (
        [string]$Threshold      = $null,
        $InputValue             = $null,
        $BaseValue              = $null,
        [switch]$Matches        = $FALSE,
        [switch]$NotMatches     = $FALSE,
        [switch]$DateTime       = $FALSE,
        [string]$Unit           = '',
        $ThresholdCache         = $null,
        [string]$CheckName      = '',
        [string]$PerfDataLabel  = '',
        [hashtable]$Translation = @{ },
        $Minium                 = $null,
        $Maximum                = $null,
        [switch]$IsBetween      = $FALSE,
        [switch]$IsLowerEqual   = $FALSE,
        [switch]$IsGreaterEqual = $FALSE,
        [string]$TimeInterval   = $null,
        [switch]$NoPerfData     = $FALSE
    );

    try {
        # Fix possible numeric value comparison issues
        $TestInput = Test-IcingaDecimal $InputValue;
        $BaseInput = Test-IcingaDecimal $BaseValue;
        $MoTData   = @{
            'Label'    = $PerfDataLabel;
            'Interval' = $TimeInterval;
        };

        # Ensure we do not include our checks for which we do not write any performance data
        # Metrics over time will not work for those, as the metrics are not stored.
        # There just set the variable to null which means they won't be processed
        if ($NoPerfData) {
            $MoTData = $null;
        }

        if ($TestInput.Decimal) {
            [decimal]$InputValue = [decimal]$TestInput.Value;
        }
        if ($BaseInput.Decimal) {
            [decimal]$BaseValue = [decimal]$BaseInput.Value;
        }

        $IcingaThresholds = New-Object -TypeName PSObject;
        $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'Value'     -Value $InputValue;
        $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'Unit'      -Value $Unit;
        $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'Message'   -Value '';
        $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'IsOK'      -Value $FALSE;
        $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'HasError'  -Value $FALSE;
        $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'Threshold' -Value (Convert-IcingaPluginThresholds -Threshold $Threshold);
        $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'Minimum'   -Value (Convert-IcingaPluginThresholds -Threshold $Minium);
        $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'Maximum'   -Value (Convert-IcingaPluginThresholds -Threshold $Maximum);

        # In case we are using % values, we should set the BaseValue always to 100
        if ($Unit -eq '%' -And $null -eq $BaseValue) {
            $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'BaseValue' -Value 100;
        } else {
            $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'BaseValue' -Value $BaseValue;
        }

        $CheckResult = $null;

        if ($Matches) {
            $CheckResult = Compare-IcingaPluginValueToThreshold -Value $InputValue -BaseValue $IcingaThresholds.BaseValue -Threshold $IcingaThresholds.Threshold -Unit $Unit -Translation $Translation -OverrideMode $IcingaEnums.IcingaThresholdMethod.Matches -MetricsOverTime $MoTData;
        } elseif ($NotMatches) {
            $CheckResult = Compare-IcingaPluginValueToThreshold -Value $InputValue -BaseValue $IcingaThresholds.BaseValue -Threshold $IcingaThresholds.Threshold -Unit $Unit -Translation $Translation -OverrideMode $IcingaEnums.IcingaThresholdMethod.NotMatches -MetricsOverTime $MoTData;
        } elseif ($IsBetween) {
            $CheckResult = Compare-IcingaPluginValueToThreshold -Value $InputValue -BaseValue $IcingaThresholds.BaseValue -Threshold $IcingaThresholds.Threshold -Unit $Unit -Translation $Translation -OverrideMode $IcingaEnums.IcingaThresholdMethod.Between -MetricsOverTime $MoTData;
        } elseif ($IsLowerEqual) {
            $CheckResult = Compare-IcingaPluginValueToThreshold -Value $InputValue -BaseValue $IcingaThresholds.BaseValue -Threshold $IcingaThresholds.Threshold -Unit $Unit -Translation $Translation -OverrideMode $IcingaEnums.IcingaThresholdMethod.LowerEqual -MetricsOverTime $MoTData;
        } elseif ($IsGreaterEqual) {
            $CheckResult = Compare-IcingaPluginValueToThreshold -Value $InputValue -BaseValue $IcingaThresholds.BaseValue -Threshold $IcingaThresholds.Threshold -Unit $Unit -Translation $Translation -OverrideMode $IcingaEnums.IcingaThresholdMethod.GreaterEqual -MetricsOverTime $MoTData;
        } else {
            $CheckResult = Compare-IcingaPluginValueToThreshold -Value $InputValue -BaseValue $IcingaThresholds.BaseValue -Threshold $IcingaThresholds.Threshold -Unit $Unit -Translation $Translation -MetricsOverTime $MoTData;
        }

        $IcingaThresholds.Message  = $CheckResult.Message;
        $IcingaThresholds.IsOK     = $CheckResult.IsOK;
        $IcingaThresholds.HasError = $CheckResult.HasError;

        return $IcingaThresholds;
    } catch {
        $IcingaThresholds = New-Object -TypeName PSObject;
        $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'Value'     -Value $InputValue;
        $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'Unit'      -Value $Unit;
        $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'Message'   -Value $_.Exception.Message;
        $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'IsOK'      -Value $FALSE;
        $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'HasError'  -Value $TRUE;
        $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'Threshold' -Value $Threshold;
        $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'Minimum'   -Value $Minium;
        $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'Maximum'   -Value $Maximum;

        return $IcingaThresholds;
    }

    return $null;
}
