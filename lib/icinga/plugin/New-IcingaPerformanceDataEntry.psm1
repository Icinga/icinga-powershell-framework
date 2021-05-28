function New-IcingaPerformanceDataEntry()
{
    param (
        $PerfDataObject,
        $Label          = $null,
        $Value          = $null,
        $Warning        = $null,
        $Critical       = $null
    );

    if ($null -eq $PerfDataObject) {
        return '';
    }

    [string]$LabelName     = $PerfDataObject.label;
    [string]$PerfValue     = $PerfDataObject.value;
    [string]$WarningValue  = $PerfDataObject.warning;
    [string]$CriticalValue = $PerfDataObject.critical;

    if ([string]::IsNullOrEmpty($Label) -eq $FALSE) {
        $LabelName = $Label;
    }
    if ([string]::IsNullOrEmpty($Value) -eq $FALSE) {
        $PerfValue = $Value;
    }

    # Override our warning/critical values only if the label does not match.
    # Eg. Core_1 not matching Core_1_5 - this is only required for time span checks
    if ([string]::IsNullOrEmpty($Label) -eq $FALSE -And $Label -ne $PerfDataObject.label) {
        $WarningValue  = $Warning;
        $CriticalValue = $Critical;
    }

    $minimum = '';
    $maximum = '';

    if ([string]::IsNullOrEmpty($PerfDataObject.minimum) -eq $FALSE) {
        $minimum = [string]::Format(';{0}', $PerfDataObject.minimum);
    }
    if ([string]::IsNullOrEmpty($PerfDataObject.maximum) -eq $FALSE) {
        $maximum = [string]::Format(';{0}', $PerfDataObject.maximum);
    }

    return (
        [string]::Format(
            "'{0}'={1}{2};{3};{4}{5}{6} ",
            $LabelName.ToLower(),
            (Format-IcingaPerfDataValue $PerfValue),
            $PerfDataObject.unit,
            (Format-IcingaPerfDataValue $WarningValue),
            (Format-IcingaPerfDataValue $CriticalValue),
            (Format-IcingaPerfDataValue $minimum),
            (Format-IcingaPerfDataValue $maximum)
        )
    );
}
