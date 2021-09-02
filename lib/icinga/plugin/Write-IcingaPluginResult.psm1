function Write-IcingaPluginResult()
{
    param (
        [string]$PluginOutput  = '',
        [array]$PluginPerfData = @()
    );

    [string]$CheckResult = $PluginOutput;

    if ($PluginPerfData -ne 0) {
        $CheckResult += "`n`r| ";
        foreach ($PerfData in $PluginPerfData) {
            $CheckResult += $PerfData;
        }
    }

    Write-IcingaConsolePlain $CheckResult;
}
