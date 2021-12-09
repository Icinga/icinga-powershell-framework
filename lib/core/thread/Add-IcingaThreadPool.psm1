function Add-IcingaThreadPool()
{
    param (
        [string]$Name      = '',
        [int]$MinInstances = 1,
        [int]$MaxInstances = 5
    );

    if ($Global:Icinga.Public.ThreadPools.ContainsKey($Name)) {
        return;
    }

    $Global:Icinga.Public.ThreadPools.Add(
        $Name,
        (New-IcingaThreadPool -MinInstances $MinInstances -MaxInstances $MaxInstances)
    );
}
