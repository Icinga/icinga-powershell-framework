function New-IcingaTCPClient()
{
    param(
        [System.Net.Sockets.TcpListener]$Socket = $null
    );

    if ($null -eq $Socket) {
        return $null;
    }

    [System.Net.Sockets.TcpClient]$Client = $Socket.AcceptTcpClient();

    return $Client;
}
