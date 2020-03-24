function Open-IcingaTCPClientConnection()
{
    param(
        [System.Net.Sockets.TcpClient]$Client                                 = $null,
        [Security.Cryptography.X509Certificates.X509Certificate2]$Certificate = $null
    );

    if ($null -eq $Client -Or $null -eq $Certificate) {
        return $null;
    }

    $Stream = New-IcingaSSLStream -Client $Client -Certificate $Certificate;

    return @{
        'Client' = $Client;
        'Stream' = $Stream;
    };
}
