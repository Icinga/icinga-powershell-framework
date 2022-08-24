function New-IcingaPerformanceDataEntry()
{
    param (
        $PerfDataObject,
        $Label               = $null,
        $Value               = $null,
        $Warning             = $null,
        $Critical            = $null,
        [hashtable]$PerfData = @{ },
        [string]$Interval    = ''
    );

    if ($null -eq $PerfDataObject) {
        return $PerfData;
    }

    [string]$MetricIndex   = $PerfDataObject.index;
    [string]$MetricName    = $PerfDataObject.name;
    [string]$LabelName     = $PerfDataObject.label;
    [string]$Template      = $PerfDataObject.template;
    [string]$PerfValue     = $PerfDataObject.value;
    [string]$WarningValue  = $PerfDataObject.warning;
    [string]$CriticalValue = $PerfDataObject.critical;

    if ([string]::IsNullOrEmpty($Label) -eq $FALSE) {
        $LabelName      = $Label;
        $MetricInterval = $Label.Split('::')[-1];
        $MetricName     = [string]::Format('{0}::{1}', $MetricName, $MetricInterval);
    }
    if ([string]::IsNullOrEmpty($Value) -eq $FALSE) {
        $PerfValue = $Value;
    }

    # Override our warning/critical values only if the label does not match.
    # Eg. Core_1 not matching Core_1_5 - this is only required for time span checks
    if ([string]::IsNullOrEmpty($Label) -eq $FALSE -And [string]::IsNullOrEmpty($Interval) -eq $FALSE -And $Label.Contains([string]::Format('::Interval{0}', $Interval))) {
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

    [string]$MultiLabelName = '';
    $LabelName              = [string]::Format('{0}::ifw_{1}::{2}', $MetricIndex, $Template, $MetricName).Replace('::::', '::');

    if ($LabelName.Contains('::Interval') -eq $FALSE) {
        if ($PerfData.ContainsKey($LabelName) -eq $FALSE) {
            $PerfData.Add(
                $LabelName,
                @{
                    'Index'  = '';
                    'Values' = @()
                }
            );
        }
    }

    if ([string]::IsNullOrEmpty($LabelName) -eq $FALSE -And $LabelName.Contains('::Interval')) {
        $IntervalName   = $LabelName.Split('::')[-1];
        $LabelInterval  = $IntervalName.Replace('Interval', '');
        $MetricName     = $LabelName.Split('::')[4];
        $MultiLabelName = [string]::Format('{0}{1}', $MetricName, (ConvertTo-IcingaNumericTimeIndex -TimeValue $LabelInterval));
        $LabelName      = [string]::Format('{0}::ifw_{1}::{2}', $MetricIndex, $Template, $MetricName);
    } else {
        $MultiLabelName = $LabelName;
    }

    $PerfDataOutput = [string]::Format(
        "'{0}'={1}{2};{3};{4}{5}{6}",
        $MultiLabelName.ToLower(),
        (Format-IcingaPerfDataValue $PerfValue),
        $PerfDataObject.unit,
        (Format-IcingaPerfDataValue $WarningValue),
        (Format-IcingaPerfDataValue $CriticalValue),
        (Format-IcingaPerfDataValue $minimum),
        (Format-IcingaPerfDataValue $maximum)
    );

    if ($MultiLabelName.Contains('::ifw_')) {
        $PerfData[$LabelName].Index = $PerfDataOutput;
    } else {
        $PerfData[$LabelName].Values += $PerfDataOutput;
    }

    return $PerfData;
}
