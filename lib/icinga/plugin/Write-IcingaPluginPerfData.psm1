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

    if ($Global:Icinga.Protected.RunAsDaemon -eq $FALSE -And $Global:Icinga.Protected.JEAContext -eq $FALSE) {
        [string]$PerfDataOutput = (Get-IcingaPluginPerfDataContent -PerfData $PerformanceData -CheckResultCache $CheckResultCache -IcingaCheck $IcingaCheck);
        Write-IcingaConsolePlain ([string]::Format('| {0}', $PerfDataOutput));
    } else {
        [void](Get-IcingaPluginPerfDataContent -PerfData $PerformanceData -CheckResultCache $CheckResultCache -AsObject $TRUE -IcingaCheck $IcingaCheck);
    }
}

function Get-IcingaPluginPerfDataContent()
{
    param(
        $PerfData,
        $CheckResultCache,
        [bool]$AsObject = $FALSE,
        $IcingaCheck    = $null
    );

    [string]$PerfDataOutput = '';

    foreach ($package in $PerfData.Keys) {
        $data = $PerfData[$package];
        if ($data.package) {
            $PerfDataOutput += (Get-IcingaPluginPerfDataContent -PerfData $data.perfdata -CheckResultCache $CheckResultCache -AsObject $AsObject -IcingaCheck $IcingaCheck);
        } else {
            foreach ($checkresult in $CheckResultCache.PSobject.Properties) {

                $SearchPattern = [string]::Format('{0}_', $data.label);
                $SearchEntry   = $checkresult.Name;
                if ($SearchEntry -like "$SearchPattern*") {
                    $TimeSpan  = $IcingaCheck.__GetTimeSpanThreshold($SearchEntry, $data.label);

                    $cachedresult = (New-IcingaPerformanceDataEntry -PerfDataObject $data -Label $SearchEntry -Value $checkresult.Value -Warning $TimeSpan.Warning -Critical $TimeSpan.Critical);

                    if ($AsObject) {
                        # New behavior with local thread separated results
                        $global:Icinga.Private.Scheduler.PerformanceData += $cachedresult;
                    }
                    $PerfDataOutput += $cachedresult;
                }
            }

            $compiledPerfData = (New-IcingaPerformanceDataEntry $data);

            if ($AsObject) {
                # New behavior with local thread separated results
                $global:Icinga.Private.Scheduler.PerformanceData += $compiledPerfData;
            }
            $PerfDataOutput += $compiledPerfData;
        }
    }

    return $PerfDataOutput;
}

Export-ModuleMember -Function @( 'Write-IcingaPluginPerfData' );
