function Close-IcingaTCPSocket()
{
    param(
        [System.Net.Sockets.TcpListener]$Socket = $null
    );

    if ($null -eq $Socket) {
        return;
    }

    $Socket.Stop();
}
