function Close-IcingaTCPSocket()
{
    param(
        [System.Net.Sockets.TcpListener]$Socket = $null
    );

    if ($null -eq $Socket) {
        return;
    }

    Write-IcingaDebugMessage -Message (
        [string]::Format(
            'Closing TCP socket {0}',
            $Socket.LocalEndpoint
        )
    );

    $Socket.Stop();
}
