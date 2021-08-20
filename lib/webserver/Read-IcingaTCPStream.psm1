function Read-IcingaTCPStream()
{
    param(
        [System.Net.Sockets.TcpClient]$Client  = @{},
        [System.Net.Security.SslStream]$Stream = $null,
        [int]$ReadLength                       = 0
    );

    if ($ReadLength -eq 0) {
        $ReadLength = $Client.ReceiveBufferSize;
    }

    if ($null -eq $Stream) {
        return $null;
    }

    # Get the maxium size of our buffer
    [byte[]]$bytes   = New-Object byte[] $ReadLength;
    # Read the content of our SSL stream
    $MessageSize     = $Stream.Read($bytes, 0, $ReadLength);
    # Resize our array to the correct size
    [byte[]]$resized = New-Object byte[] $MessageSize;
    [array]::Copy($bytes, 0, $resized, 0, $MessageSize);

    Write-IcingaDebugMessage -Message 'Network Stream message size' -Objects $MessageSize;
    Write-IcingaDebugMessage -Message 'Network Stream message in bytes' -Objects $resized;

    # Return our message content
    return [System.Text.Encoding]::UTF8.GetString($resized);
}
