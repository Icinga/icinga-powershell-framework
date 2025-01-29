function ConvertTo-IcingaMetricsOverTime()
{
    param (
        $MetricsOverTime = $null
    );

    $MoTObj = @{
        'Value'   = $null;
        'Message' = '';
        'Apply'   = $FALSE;
        'Error'   = $FALSE;
    }

    if ($MetricsOverTime -eq $null) {
        return $MoTObj;
    }

    if ([string]::IsNullOrEmpty($MetricsOverTime.Interval)) {
        return $MoTObj;
    }

    try {
        [int]$IntervalInSeconds  = ConvertTo-Seconds -Value $MetricsOverTime.Interval;
        $MoTPerfData             = Get-IcingaMetricsOverTimePerfData;
        [array]$MoTToArray       = $MoTPerfData.Split(' ');
        [string]$SearchLabel     = [string]::Format('{0}::Interval{1}', $MetricsOverTime.Label, $IntervalInSeconds);
        [hashtable]$AvailableMoT = @{ };

        foreach ($mot in $MoTToArray) {
            if ([string]::IsNullOrEmpty($mot) -Or $mot.Contains('=') -eq $FALSE) {
                continue;
            }

            $MoTPerfData   = $mot.Split('=');
            $TimeIndexName = [string]::Format('{0}s', $MoTPerfData[0].Split('::')[-1].Replace('Interval', ''));

            if ($AvailableMoT.ContainsKey($TimeIndexName) -eq $FALSE) {
                $AvailableMoT.Add($TimeIndexName, $TRUE);
            }

            if ($MoTPerfData[0] -eq $SearchLabel) {
                $MoTObj.Value   = $MoTPerfData[1];
                $MoTObj.Apply   = $TRUE;
                $MoTObj.Message = [string]::Format(' ({0} Avg.)', $MetricsOverTime.Interval);
                break;
            }
        }

        if ($MoTObj.Apply -eq $FALSE) {
            $MoTObj.Message = [string]::Format('[Failed to parse metrics over time with -ThresholdInterval "{0}": No data found matching the requested time index. Available indexes: [{1}]]', $MetricsOverTime.Interval, ($AvailableMoT.Keys -Join ', '));
            $MoTObj.Error   = $TRUE;
        }
    } catch {
        $MoTObj.Message = [string]::Format('[Failed to parse metrics over time with -ThresholdInterval "{0}": {1}]', $MetricsOverTime.Interval, $_.Exception.Message);
        $MoTObj.Error   = $TRUE;
    }

    return $MoTObj;
}
