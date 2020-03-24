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

    Write-IcingaDebugMessage -Message (
        [string]::Format(
            'Creating new TCP socket on Port {0}. Endpoint configuration {1}',
            $Port,
            $TCPSocket.LocalEndpoint
        )
    );

    if ($Start) {
        Write-IcingaDebugMessage -Message (
            [string]::Format(
                'Starting TCP socket for endpoint {0}',
                $TCPSocket.LocalEndpoint
            )
        );
        $TCPSocket.Start();
    }

    return $TCPSocket;
}
