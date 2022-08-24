function Write-IcingaPluginPerfData()
{
    param (
        $IcingaCheck = $null
    );

    if ($null -eq $IcingaCheck) {
        return;
    }

    $PerformanceData = $IcingaCheck.__GetPerformanceData();
    $CheckCommand    = $IcingaCheck.__GetCheckCommand();

    if ($PerformanceData.package -eq $FALSE) {
        $PerformanceData = @{
            $PerformanceData.label = $PerformanceData;
        }
    } else {
        $PerformanceData = $PerformanceData.perfdata;
    }

    if ([string]::IsNullOrEmpty($CheckCommand) -eq $FALSE -And $Global:Icinga.Private.Scheduler.ThresholdCache.ContainsKey($CheckCommand)) {
        $CheckResultCache = $Global:Icinga.Private.Scheduler.ThresholdCache[$CheckCommand];
    } else {
        $CheckResultCache = New-Object PSCustomObject;
    }

    Get-IcingaPluginPerfDataContent -PerfData $PerformanceData -CheckResultCache $CheckResultCache -IcingaCheck $IcingaCheck;

    if ($Global:Icinga.Protected.RunAsDaemon -eq $FALSE -And $Global:Icinga.Protected.JEAContext -eq $FALSE) {
        if ($Global:Icinga.Private.Scheduler.PerformanceData.Count -ne 0) {
            Write-IcingaConsolePlain ([string]::Format('| {0}', ([string]::Join(' ', $Global:Icinga.Private.Scheduler.PerformanceData))));
        }
    }
}

function Get-IcingaPluginPerfDataContent()
{
    param (
        $PerfData,
        $CheckResultCache,
        $IcingaCheck      = $null
    );

    [hashtable]$CompiledPerfData = @{ };

    foreach ($package in $PerfData.Keys) {
        $data = $PerfData[$package];
        if ($data.package) {
            (Get-IcingaPluginPerfDataContent -PerfData $data.perfdata -CheckResultCache $CheckResultCache -IcingaCheck $IcingaCheck);
        } else {
            $CompiledPerfData = New-IcingaPerformanceDataEntry -PerfDataObject $data -PerfData $CompiledPerfData;

            foreach ($checkresult in $CheckResultCache.PSobject.Properties) {

                $SearchPattern      = [string]::Format('{0}_', $data.label);
                $SearchPatternMulti = [string]::Format('::{0}::Interval', $data.multilabel);
                $SearchEntry        = $checkresult.Name;

                if ($SearchEntry -like "$SearchPatternMulti*") {
                    $TimeSpan          = $IcingaCheck.__GetTimeSpanThreshold($SearchEntry, $data.multilabel, $TRUE);
                    $CompiledPerfData = New-IcingaPerformanceDataEntry -PerfDataObject $data -Label $SearchEntry -Value $checkresult.Value -Warning $TimeSpan.Warning -Critical $TimeSpan.Critical -Interval $TimeSpan.Interval -PerfData $CompiledPerfData;
                }
            }
        }
    }

    foreach ($entry in $CompiledPerfData.Keys) {
        $entryValue            = $CompiledPerfData[$entry];
        [string]$PerfDataLabel = $entryValue.Index;

        if ($entryValue.Values.Count -ne 0) {
            [string]$PerfDataLabel = [string]::Format('{0} {1}', $entryValue.Index, ([string]::Join(' ', ($entryValue.Values | Sort-Object))));
        }

        [array]$global:Icinga.Private.Scheduler.PerformanceData += $PerfDataLabel;
    }

    [array]$global:Icinga.Private.Scheduler.PerformanceData = $Global:Icinga.Private.Scheduler.PerformanceData | Sort-Object @{
        expression = { $_.Substring(1, $_.IndexOf('::') - 1) -As [int] }
    };
}

Export-ModuleMember -Function @( 'Write-IcingaPluginPerfData' );
