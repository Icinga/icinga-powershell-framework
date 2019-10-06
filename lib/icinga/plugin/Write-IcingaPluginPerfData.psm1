function Write-IcingaPluginPerfData()
{
    param(
        $PerformanceData,
        $CheckCommand
    );

    $CheckResultCache = Get-IcingaCacheData -Space 'sc_daemon' -CacheStore 'checkresult' -KeyName $CheckCommand;

    if ($global:IcingaDaemonData.FrameworkRunningAsDaemon -eq $FALSE) {
        [string]$PerfDataOutput = (Get-IcingaPluginPerfDataContent -PerfData $PerformanceData -CheckResultCache $CheckResultCache);
        Write-Host ([string]::Format('| {0}', $PerfDataOutput));
    } else {
        [void](Get-IcingaPluginPerfDataContent -PerfData $PerformanceData -CheckResultCache $CheckResultCache -AsObject $TRUE);
    }
}

function Get-IcingaPluginPerfDataContent()
{
    param(
        $PerfData,
        $CheckResultCache,
        [bool]$AsObject = $FALSE
    );

    [string]$PerfDataOutput = '';

    foreach ($package in $PerfData.Keys) {
        $data = $PerfData[$package];
        if ($data.package) {
            $PerfDataOutput += (Get-IcingaPluginPerfDataContent -PerfData $data.perfdata -CheckResultCache $CheckResultCache -AsObject $AsObject);
        } else {
            foreach ($checkresult in $CheckResultCache.PSobject.Properties) {
                $SearchPattern = [string]::Format('{0}_', $data.label);
                $SearchEntry   = $checkresult.Name;
                if ($SearchEntry -like "$SearchPattern*") {
                    $cachedresult = (New-IcingaPerformanceDataEntry -PerfDataObject $data -Label $SearchEntry -Value $checkresult.Value);

                    if ($AsObject) {
                        if ($global:IcingaDaemonData.IcingaThreadContent.ContainsKey('Scheduler')) {
                            $global:IcingaDaemonData.IcingaThreadContent['Scheduler']['PluginPerfData'] += $cachedresult;
                        }
                    }
                    $PerfDataOutput += $cachedresult;
                }
            }

            $compiledPerfData = (New-IcingaPerformanceDataEntry $data);

            if ($AsObject) {
                if ($global:IcingaDaemonData.IcingaThreadContent.ContainsKey('Scheduler')) {
                    $global:IcingaDaemonData.IcingaThreadContent['Scheduler']['PluginPerfData'] += $compiledPerfData;
                }
            }
            $PerfDataOutput += $compiledPerfData;
        }
    }

    return $PerfDataOutput;
}

Export-ModuleMember -Function @( 'Write-IcingaPluginPerfData' );
