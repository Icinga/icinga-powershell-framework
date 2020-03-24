function Close-IcingaTCPConnection()
{
    param(
        [System.Net.Sockets.TcpClient]$Client = $null
    );

    if ($null -eq $Client) {
        return;
    }

    $Client.Close();
    $Client.Dispose();
    $Client = $null;
}
