function Write-IcingaPluginPerfData()
{
    param(
        $PerformanceData
    );

        [string]$PerfDataOutput = (Get-IcingaPluginPerfDataContent -PerfData $PerformanceData);
        Write-Host ([string]::Format('| {0}', $PerfDataOutput));
}

function Get-IcingaPluginPerfDataContent()
{
    param(
        $PerfData,
        [bool]$AsObject = $FALSE
    );

    [string]$PerfDataOutput = '';

    foreach ($package in $PerfData.Keys) {
        $data = $PerfData[$package];
        if ($data.package) {
            $PerfDataOutput += (Get-IcingaPluginPerfDataContent -PerfData $data.perfdata -AsObject $AsObject);
        } else {
            $PerfDataOutput += $data.perfdata;
        }
    }

    return $PerfDataOutput;
}

Export-ModuleMember -Function @( 'Write-IcingaPluginPerfData' );
