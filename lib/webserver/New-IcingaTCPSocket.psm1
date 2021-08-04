function New-IcingaTCPSocket()
{
    param (
        [string]$Address = '',
        [int]$Port       = 0,
        [switch]$Start   = $FALSE
    );

    if ($Port -eq 0) {
        throw 'Please specify a valid port to open a TCP socket for';
    }

    # Listen on localhost by default
    $ListenAddress = New-Object System.Net.IPEndPoint([IPAddress]::Loopback, $Port);

    if ([string]::IsNullOrEmpty($Address) -eq $FALSE) {
        $ListenAddress = New-Object System.Net.IPEndPoint([IPAddress]::Parse($Address), $Port);
    }

    $TCPSocket = New-Object 'System.Net.Sockets.TcpListener' $ListenAddress;

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
