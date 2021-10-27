function Test-IcingaRESTClientConnection()
{
    param(
        [Hashtable]$Connection = @{}
    );

    # If we couldn't establish a proper SSL stream, close the connection
    # immediately without opening a client connection thread
    if ($null -eq $Connection.Stream) {
        Add-IcingaRESTClientBlacklistCount `
            -Client $Connection.Client `
            -ClientList $IcingaDaemonData.BackgroundDaemon.IcingaPowerShellRestApi.ClientBlacklist;
        Write-IcingaEventMessage -EventId 1501 -Namespace 'Framework' -Objects $Connection.Client.Client;
        Close-IcingaTCPConnection -Client $Connection.Client;
        $Connection = $null;
        return $FALSE;
    }

    Write-IcingaDebugMessage 'Client connection has passed Test';

    return $TRUE;
}
