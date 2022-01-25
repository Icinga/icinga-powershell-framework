function Read-IcingaCheckResultStore()
{
    param (
        $CheckCommand
    );

    $LoadedCacheData = Get-IcingaCacheData -Space 'sc_daemon' -CacheStore 'checkresult_store' -KeyName $CheckCommand;

    if ($null -ne $LoadedCacheData) {
        foreach ($entry in $LoadedCacheData.PSObject.Properties) {
            $Global:Icinga.Private.Scheduler.CheckData[$CheckCommand]['results'].Add(
                $entry.name,
                @{ }
            );
            foreach ($item in $entry.Value.PSObject.Properties) {
                $Global:Icinga.Private.Scheduler.CheckData[$CheckCommand]['results'][$entry.name].Add(
                    $item.Name,
                    $item.Value
                );
            }
        }
    }
}
