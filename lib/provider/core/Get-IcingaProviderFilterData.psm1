function Get-IcingaProviderFilterData()
{
    param (
        [string]$ProviderName      = '',
        [hashtable]$ProviderFilter = @{ }
    );

    [hashtable]$FilterResult = @{ };

    foreach ($filterObject in $ProviderFilter.Keys) {
        if ($filterObject.ToLower() -ne $ProviderName.ToLower()) {
            continue;
        }

        if ($FilterResult.ContainsKey($filterObject) -eq $FALSE) {
            $FilterResult.Add(
                $filterObject,
                (New-IcingaProviderFilterObject -ProviderName $ProviderName -HashtableFilter $ProviderFilter[$filterObject])
            );
        }
    }

    return $FilterResult;
}
