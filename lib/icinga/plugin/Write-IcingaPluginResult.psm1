function Write-IcingaPluginResult()
{
    param (
        [string]$PluginOutput  = '',
        [array]$PluginPerfData = @()
    );

    [string]$CheckResult = $PluginOutput;

    if ($PluginPerfData.Count -ne 0) {
        [string]$PerfDataContent = '';
        foreach ($PerfData in $PluginPerfData) {
            $PerfDataContent += $PerfData;
        }

        if ([string]::IsNullOrEmpty($PerfDataContent) -eq $FALSE) {
            $CheckResult += "`n`r| ";
            $CheckResult += $PerfDataContent;
        }
    }

    Write-IcingaConsolePlain $CheckResult;
}
