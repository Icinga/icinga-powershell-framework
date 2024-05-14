function New-IcingaSSLStream()
{
    param(
        [System.Net.Sockets.TcpClient]$Client                                 = $null,
        [Security.Cryptography.X509Certificates.X509Certificate2]$Certificate = $null
    );

    if ($null -eq $Client) {
        return $null;
    }

    [System.Net.Security.SslStream]$SSLStream = $null;

    try {
        $SSLStream    = New-Object System.Net.Security.SslStream($Client.GetStream(), $false);
        $TLSProtocols = [System.Security.Authentication.SslProtocols]::Tls12 -bor [System.Security.Authentication.SslProtocols]::Tls13;
        $SSLStream.AuthenticateAsServer($Certificate, $false, $TLSProtocols, $true) | Out-Null;
    } catch {
        if ($null -ne $SSLStream) {
            $SSLStream.Close();
            $SSLStream.Dispose();
            $SSLStream = $null;
        }
        Write-IcingaEventMessage -EventId 1500 -Namespace 'Framework' -ExceptionObject $_ -Objects $Client.Client;
        return $null;
    }

    return $SSLStream;
}
