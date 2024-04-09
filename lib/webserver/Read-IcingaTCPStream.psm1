function Read-IcingaTCPStream()
{
    param(
        [System.Net.Sockets.TcpClient]$Client  = @{ },
        [System.Net.Security.SslStream]$Stream = $null,
        [int]$ReadLength                       = 0
    );

    [bool]$UnknownMessageSize = $FALSE;
    [int]$TimeoutInSeconds    = 5;

    if ($ReadLength -eq 0) {
        $ReadLength         = $Client.ReceiveBufferSize;
        $UnknownMessageSize = $TRUE;
    }

    if ($null -eq $Stream) {
        return $null;
    }

    # Ensure that our stream will timeout after a while to not block
    # the API permanently
    $Stream.ReadTimeout    = $TimeoutInSeconds * 1000;
    # Get the maxium size of our buffer
    [int]$MessageSize      = 0;
    [byte[]]$bytes         = New-Object byte[] $ReadLength;
    [int]$DebugReadLength  = $ReadLength;
    [int]$EmptyStreamCount = 0;
    # Ensure we calculate our own timeouts for the API, in case some malicious actions take place
    # and we only receive one byte each second for a large message. We should terminate the request
    # in this case
    $ReadTimeout           = [DateTime]::Now;

    while ($ReadLength -ne 0) {
        # Create a buffer element to store our message size into
        [byte[]]$buffer = New-Object byte[] $ReadLength;
        # Read the content of our SSL stream
        $ReadBytes      = $Stream.Read($buffer, 0, $ReadLength);
        # Now lets copy all read bytes from our buffer to our bytes variable
        # As we might read multiple times from our stream, we have to read
        # the entire buffer from index 0 and copy our content to our bytes
        # variable, while our starting index is always at the last message
        # sizes end (Message size equals ReadBytes from the previous attempt)
        # and we need to copy as much bytes to our new array, as we read
        [array]::Copy($buffer, 0, $bytes, $MessageSize, $ReadBytes);

        $ReadLength  -= $ReadBytes;
        $MessageSize += $ReadBytes;

        # In case the client terminates the session, we might receive a bunch of invalid
        # information. Just to make sure there is no other error happening,
        # we should wait a little to check if the client is still present and
        # trying to send data
        if ($ReadBytes -eq 0) {
            $EmptyStreamCount += 1;
            Start-Sleep -Milliseconds 100;
        }

        if ($EmptyStreamCount -gt 20) {
            # This would mean we waited 2 seconds to receive actual data, the client decide not to do anything
            # We should terminate this session

            Send-IcingaTCPClientMessage -Message (
                New-IcingaTCPClientRESTMessage `
                    -HTTPResponse ($IcingaHTTPEnums.HTTPResponseType.'Internal Server Error') `
                    -ContentBody @{ 'message' = 'The Icinga for Windows API received no data while reading the TCP stream. The session was terminated to protect the API.' }
            ) -Stream $Stream;

            Close-IcingaTCPConnection -Connection @{ 'Client' = $Client; 'Stream' = $Stream; };

            Write-IcingaDebugMessage `
                -Message 'Icinga for Windows API received multiple empty results and attempts from the client. Terminating session.' `
                -Objects $DebugReadLength, $ReadBytes, $ReadLength, $MessageSize;

            # Return an empty JSON
            return '{ }';
        }

        if ((([DateTime]::Now) - $ReadTimeout).TotalSeconds -gt $TimeoutInSeconds -And $ReadLength -ne 0) {
            # This would mean we waited to long to receive the entire message
            # We should terminate this session, in case we have't just completed the read
            # of our message

            Send-IcingaTCPClientMessage -Message (
                New-IcingaTCPClientRESTMessage `
                    -HTTPResponse ($IcingaHTTPEnums.HTTPResponseType.'Gateway Timeout') `
                    -ContentBody @{ 'message' = 'The Icinga for Windows API waited too long to receive the entire message from the client. The session was terminated to protect the API.' }
            ) -Stream $Stream;

            Close-IcingaTCPConnection -Connection @{ 'Client' = $Client; 'Stream' = $Stream; };

            Write-IcingaDebugMessage `
                -Message 'Icinga for Windows API waited too long to receive the entire message from the client. Terminating session.' `
                -Objects $DebugReadLength, $ReadBytes, $ReadLength, $MessageSize;

            # Return an empty JSON
            return '{ }';
        }

        # In case our client did not set a defined message size, we just take the default from the Client
        # In most cases, the client will default to 65536 as network buffer for this and we should just
        # pretend the message was send properly. In most cases, the important request will go through
        # as this will only happen to the first message. Afterwards we can use the HTTP headers to read
        # the actual content size of the message
        if ($UnknownMessageSize) {
            Write-IcingaDebugMessage `
                -Message 'Message buffer for incoming network stream was 65536. Assuming we read all data' `
                -Objects $DebugReadLength, $ReadBytes, $ReadLength, $MessageSize;

            break;
        }

        # Just some debug context, allowing us to check what is going on with the API
        Write-IcingaDebugMessage `
            -Message 'Network stream output while parsing request. Request Size / Read Bytes / Remaining Size / Message Size' `
            -Objects $DebugReadLength, $ReadBytes, $ReadLength, $MessageSize;
    }

    # Resize our array to the correct size, as we might have read
    # 65536 bytes because of our client not sending the correct length
    [byte[]]$resized = New-Object byte[] $MessageSize;
    [array]::Copy($bytes, 0, $resized, 0, $MessageSize);

    Write-IcingaDebugMessage -Message 'Network Stream message size' -Objects $MessageSize;
    Write-IcingaDebugMessage -Message 'Network Stream message in bytes' -Objects $resized;

    # Return our message content
    return [System.Text.Encoding]::UTF8.GetString($resized);
}
