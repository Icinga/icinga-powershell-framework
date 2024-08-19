function Write-IcingaPluginResult()
{
    param (
        [string]$PluginOutput   = '',
        [string]$PluginPerfData = ''
    );

    [string]$CheckResult = $PluginOutput;

    if ([string]::IsNullOrEmpty($PluginPerfData) -eq $FALSE) {
        $CheckResult = [string]::Format('{0}{1}| {2}', $CheckResult, "`r`n", $PluginPerfData);
    }

    Write-IcingaConsolePlain $CheckResult;
}
