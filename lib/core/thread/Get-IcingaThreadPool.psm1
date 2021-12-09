function Get-IcingaThreadPool()
{
    param (
        [string]$Name
    );

    if ($Global:Icinga.Public.ThreadPools.ContainsKey($Name)) {
        return $Global:Icinga.Public.ThreadPools[$Name];
    }

    Write-IcingaEventMessage -Namespace 'Framework' -EventId 1401 -Objects $Name;

    return (New-IcingaThreadPool);
}
