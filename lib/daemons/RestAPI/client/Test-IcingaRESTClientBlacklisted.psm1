function Test-IcingaRESTClientBlacklisted()
{
    param (
        [System.Net.Sockets.TcpClient]$Client = $null,
        $ClientList                           = $null
    );

    if ($null -eq $Client) {
        return $FALSE;
    }

    [string]$Endpoint  = Get-IcingaTCPClientRemoteEndpoint -Client $Client;
    [string]$IpAddress = $Endpoint.Split(':')[0];
    [int]$Value        = Get-IcingaHashtableItem `
                            -Hashtable $ClientList `
                            -Key $IpAddress `
                            -NullValue 0;

    # After 9 invalid attempts we will blacklist the client
    if ($Value -gt 9) {
        Write-IcingaDebugMessage -Message 'Client is blacklisted' -Objects $IpAddress, $Value, $Client.Client;
        return $TRUE;
    }

    return $FALSE;
}
