function New-IcingaSSLStream()
{
    param(
        [System.Net.Sockets.TcpClient]$Client                                 = $null,
        [Security.Cryptography.X509Certificates.X509Certificate2]$Certificate = $null
    );

    if ($null -eq $Client) {
        return $null;
    }

    try {
        $SSLStream = New-Object System.Net.Security.SslStream($Client.GetStream(), $false)
        $SSLStream.AuthenticateAsServer($Certificate, $false, [System.Security.Authentication.SslProtocols]::Tls12, $true) | Out-Null;
    } catch {
        Write-IcingaEventMessage -EventId 1500 -Namespace 'Framework' -ExceptionObject $_ -Objects $Client.Client;
        return $null;
    }

    return $SSLStream;
}
