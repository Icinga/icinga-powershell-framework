function New-IcingaThreadPool()
{
    param(
        [int]$MinInstances = 1,
        [int]$MaxInstances = 5
    );

    $SessionConfiguration = $null;
    $SessionFile          = Get-IcingaJEASessionFile;

    if ([string]::IsNullOrEmpty((Get-IcingaJEAContext))) {
        $SessionConfiguration = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault();
    } else {
        if ([string]::IsNullOrEmpty($SessionFile)) {
            Write-IcingaEventMessage -EventId 1502 -Namespace 'Framework';
            return $null;
        }
        $SessionConfiguration = [System.Management.Automation.Runspaces.InitialSessionState]::CreateFromSessionConfigurationFile($SessionFile);
    }

    $Runspaces = [RunspaceFactory]::CreateRunspacePool(
        $MinInstances,
        $MaxInstances,
        $SessionConfiguration,
        $host
    )

    $Runspaces.Open();

    return $Runspaces;
}
