function New-IcingaPerformanceDataEntry()
{
    param (
        $PerfDataObject,
        $Label          = $null,
        $Value          = $null
    );

    if ($null -eq $PerfDataObject) {
        return '';
    }

    [string]$LabelName = $PerfDataObject.label;
    [string]$PerfValue = $PerfDataObject.value;

    if ([string]::IsNullOrEmpty($Label) -eq $FALSE) {
        $LabelName = $Label;
    }
    if ([string]::IsNullOrEmpty($Value) -eq $FALSE) {
        $PerfValue = $Value;
    }

    $minimum = '';
    $maximum = '';

    if ([string]::IsNullOrEmpty($PerfDataObject.minimum) -eq $FALSE) {
        $minimum = [string]::Format(';{0}', $PerfDataObject.minimum);
    }
    if ([string]::IsNullOrEmpty($PerfDataObject.maximum) -eq $FALSE) {
        $maximum = [string]::Format(';{0}', $PerfDataObject.maximum);
    }

    return ([string]::Format(
        "'{0}'={1}{2};{3};{4}{5}{6} ",
        $LabelName.ToLower(),
        (Format-IcingaPerfDataValue $PerfValue),
        $PerfDataObject.unit,
        (Format-IcingaPerfDataValue $PerfDataObject.warning),
        (Format-IcingaPerfDataValue $PerfDataObject.critical),
        (Format-IcingaPerfDataValue $minimum),
        (Format-IcingaPerfDataValue $maximum)
    ));
}
