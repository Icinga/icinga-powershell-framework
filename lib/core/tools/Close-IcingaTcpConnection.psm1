function Close-IcingaTcpConnection()
{
    param(
        $TcpClient
    );

    if ($null -eq $TcpClient) {
        return;
    }

    $TcpClient.Close();
    $TcpClient.Dispose();
    $TcpClient = $null;
}
