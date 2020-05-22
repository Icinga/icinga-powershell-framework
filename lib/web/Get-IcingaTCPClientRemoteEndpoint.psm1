function Get-IcingaTCPClientRemoteEndpoint()
{
    param(
        [System.Net.Sockets.TcpClient]$Client = $null
    );

    if ($null -eq $Client) {
        return 'unknown';
    }

    return $Client.Client.RemoteEndPoint;
}
