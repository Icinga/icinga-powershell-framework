function Read-IcingaTCPStream()
{
    param(
        [System.Net.Sockets.TcpClient]$Client  = @{},
        [System.Net.Security.SslStream]$Stream = $null
    );

    # Get the maxium size of our buffer
    [byte[]]$bytes = New-Object byte[] $Client.ReceiveBufferSize;
    # Read the content of our SSL stream
    $Stream.Read($bytes, 0, $Client.ReceiveBufferSize);

    # Now ready the actual content size of the received message
    [int]$count = 0;
    for ($i=0; $i -le $Client.ReceiveBufferSize; $i++) {
        if ($bytes[$i] -ne 0) {
            $count = $count + 1;
        } else {
            break;
        }
    }

    # Resize our array to the correct size
    [byte[]]$resized = New-Object byte[] $count;
    [array]::Copy($bytes, 0, $resized, 0, $count);

    # Return our message content
    return [System.Text.Encoding]::UTF8.GetString($resized);
}
