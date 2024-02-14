function Get-IcingaProviderData()
{
    param (
        [array]$Name            = '',
        [array]$IncludeFilter   = @(),
        [array]$ExcludeFilter   = @(),
        [switch]$IncludeDetails = $FALSE
    );

    [hashtable]$ProviderData = @{ };

    foreach ($entry in $Name) {
        [array]$ProviderDataList = Get-Command -Name ([string]::Format('Get-IcingaProviderDataValues{0}', $entry)) -ErrorAction SilentlyContinue;

        if ($null -eq $ProviderDataList -Or $ProviderDataList.Count -eq 0) {
            $ProviderData.Add($entry, 'Provider not Found');
            continue;
        }

        if ($ProviderDataList.Count -gt 1) {
            $ProviderData.Add($entry, 'Provider name not unique enough');
            continue;
        }

        if ((Test-IcingaForWindowsCmdletLoader -Path $ProviderDataList.Module.ModuleBase) -eq $FALSE) {
            $ProviderData.Add($entry, 'Security violation. Provider not installed at Framework location');
            continue;
        }

        $ProviderCmd     = $ProviderDataList[0];
        $ProviderContent = (& $ProviderCmd -IncludeDetails:$IncludeDetails -IncludeFilter $IncludeFilter -ExcludeFilter $ExcludeFilter);

        if ($ProviderData.ContainsKey($ProviderContent.Name) -eq $FALSE) {
            $ProviderData.Add($ProviderContent.Name, $ProviderContent);
        } else {
            $ProviderData[$ProviderContent.Name] = $ProviderContent;
        }
    }

    return $ProviderData;
}
