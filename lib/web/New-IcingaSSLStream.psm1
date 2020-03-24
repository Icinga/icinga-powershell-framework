function New-IcingaSSLStream()
{
    param(
        [System.Net.Sockets.TcpClient]$Client                                 = $null,
        [Security.Cryptography.X509Certificates.X509Certificate2]$Certificate = $null
    );

    if ($null -eq $Client) {
        return $null;
    }

    $SSLStream = New-Object System.Net.Security.SslStream($Client.GetStream(), $false)
    $SSLStream.AuthenticateAsServer($Certificate, $false, [System.Security.Authentication.SslProtocols]::Tls12, $true) | Out-Null;

    return $SSLStream;
}
