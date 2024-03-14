function New-IcingaProviderFilterObject()
{
    param (
        [string]$ProviderName       = '',
        [hashtable]$HashtableFilter = @{ }
    );

    if ([string]::IsNullOrEmpty($ProviderName)) {
        return @{ };
    }

    [array]$ProviderFilterCmdlet = Get-Command ([string]::Format('New-IcingaProviderFilterData{0}', $ProviderName)) -ErrorAction SilentlyContinue;

    if ($null -eq $ProviderFilterCmdlet -Or $ProviderFilterCmdlet.Count -eq 0) {
        return @{ };
    }

    if ((Test-IcingaForWindowsCmdletLoader -Path $ProviderFilterCmdlet[0].Module.ModuleBase) -eq $FALSE) {
        return @{ };
    }

    $FilterResult = & $ProviderFilterCmdlet[0].Name @HashtableFilter;

    [string]$ObjectName = $ProviderName;
    $CmdHelp            = Get-Help ($ProviderFilterCmdlet[0].Name) -ErrorAction SilentlyContinue;

    if ($null -ne $CmdHelp) {
        if ([string]::IsNullOrEmpty($CmdHelp.Role) -eq $FALSE) {
            [string]$ObjectName = [string]($CmdHelp.Role);
        }
    }

    $CmdHelp              = $null;
    $ProviderFilterCmdlet = $null;

    return @{
        $ObjectName = $FilterResult;
    };
}
