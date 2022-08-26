function Write-IcingaPluginResult()
{
    param (
        [string]$PluginOutput  = '',
        [array]$PluginPerfData = @()
    );

    [string]$CheckResult = $PluginOutput;

    if ($PluginPerfData.Count -ne 0) {
        $CheckResult = [string]::Format('{0}{1}| {2}', $CheckResult, "`r`n", ([string]::Join(' ', $PluginPerfData)));
    }

    Write-IcingaConsolePlain $CheckResult;
}
