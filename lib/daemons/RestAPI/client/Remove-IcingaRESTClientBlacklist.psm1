function Remove-IcingaRESTClientBlacklist()
{
    param (
        [System.Net.Sockets.TcpClient]$Client = $null,
        $ClientList                           = $null
    );

    if ($null -eq $Client) {
        return;
    }

    [string]$Endpoint  = Get-IcingaTCPClientRemoteEndpoint -Client $Client;
    [string]$IpAddress = $Endpoint.Split(':')[0];

    Remove-IcingaHashtableItem `
        -Hashtable $ClientList `
        -Key $IpAddress;
}
