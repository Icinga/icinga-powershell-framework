function New-IcingaThreadPool()
{
    param(
        [int]$MinInstances = 1,
        [int]$MaxInstances = 5
    );

    $Runspaces = [RunspaceFactory]::CreateRunspacePool(
        $MinInstances,
        $MaxInstances,
        [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault(),
        $host
    )

    $Runspaces.Open();

    return $Runspaces;
}
