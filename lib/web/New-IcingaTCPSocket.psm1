function New-IcingaTCPSocket()
{
    param(
        [int]$Port     = 0,
        [switch]$Start = $FALSE
    );

    if ($Port -eq 0) {
        throw 'Please specify a valid port to open a TCP socket for';
    }

    $TCPSocket = [System.Net.Sockets.TcpListener]$Port;

    if ($Start) {
        $TCPSocket.Start();
    }

    return $TCPSocket;
}
