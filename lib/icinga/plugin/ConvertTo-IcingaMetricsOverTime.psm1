function ConvertTo-IcingaMetricsOverTime()
{
    param (
        $MetricsOverTime = $null
    );

    $MoTObj = @{
        'Value'   = $null;
        'Message' = '';
        'Apply'   = $FALSE;
    }

    if ($MetricsOverTime -eq $null) {
        return $MoTObj;
    }

    [int]$IntervalInSeconds = ConvertTo-Seconds -Value $MetricsOverTime.Interval;
    $MoTPerfData            = Get-IcingaMetricsOverTimePerfData;
    [array]$MoTToArray      = $MoTPerfData.Split(' ');
    [array]$SearchLabel     = [string]::Format('{0}::Interval{1}', $MetricsOverTime.Label, $IntervalInSeconds);

    foreach ($mot in $MoTToArray) {
        if ([string]::IsNullOrEmpty($mot) -Or $mot.Contains('=') -eq $FALSE) {
            continue;
        }

        $MoTPerfData = $mot.Split('=');

        if ($MoTPerfData[0] -eq $SearchLabel) {
            $MoTObj.Value   = $MoTPerfData[1];
            $MoTObj.Apply   = $TRUE;
            $MoTObj.Message = [string]::Format(' ({0} Avg.)', $MetricsOverTime.Interval);
            break;
        }
    }

    return $MoTObj;
}
