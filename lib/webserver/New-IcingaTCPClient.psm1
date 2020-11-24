function New-IcingaTCPClient()
{
    param(
        [System.Net.Sockets.TcpListener]$Socket = $null
    );

    if ($null -eq $Socket) {
        return $null;
    }

    [System.Net.Sockets.TcpClient]$Client = $Socket.AcceptTcpClient();

    Write-IcingaDebugMessage -Message (
        [string]::Format(
            'New incoming client connection for endpoint {0}',
            (Get-IcingaTCPClientRemoteEndpoint -Client $Client)
        )
    );

    return $Client;
}
