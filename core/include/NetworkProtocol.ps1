$NetworkProtocol = New-Object -TypeName PSObject;

$NetworkProtocol | Add-Member -membertype NoteProperty -name 'static'        -value $FALSE;
$NetworkProtocol | Add-Member -membertype NoteProperty -name 'sslstream'     -value $null;
$NetworkProtocol | Add-Member -membertype NoteProperty -name 'networkstream' -value $null;
$NetworkProtocol | Add-Member -membertype NoteProperty -name 'encrypted'     -value $null;

$NetworkProtocol | Add-Member -membertype ScriptMethod -name 'Create' -value {
    param($Stream);

    $this.networkstream = $Stream;
    $this.sslstream     = $this.CreateSSLStream($Stream);
}

$NetworkProtocol | Add-Member -membertype ScriptMethod -name 'CreateSSLStream' -value {
    param($Stream);

    try {
        $sslStream = New-Object System.Net.Security.SslStream(
            $Stream,
            $false
        )
        $sslStream.AuthenticateAsServer(
            $Icinga2.Cache.Certificates.Server,
            0,
            [System.Security.Authentication.SslProtocols]::Tls,
            1
        );
        $sslStream.ReadTimeout = 2000;
        $this.encrypted = $TRUE;

        return $sslStream;
    } catch [System.IO.IOException] {
        # Exceptions which occure when connecting from HTTP to this API, as we force HTTPS
        # Use the client's non-ssl stream to inform the user about our forced
        # HTTPS handling and set an internal variable to not send any data
        # to our client over HTTP
        $this.encrypted      = $FALSE;
        $Stream.ReadTimeout  = 2000;
        $Stream.WriteTimeout = 2000;
        return $Stream;
    } catch [System.NotSupportedException] {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Exception,
            'The used SSL certificate is not providing a linked private key and cannot be used as Server certificate'
        );
    } catch {
        # Handle every other error here
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Exception,
            $_.Exception.Message
        );
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Exception,
            $_.Exception
        );
    }

    return $null;
}

$NetworkProtocol | Add-Member -membertype ScriptMethod -name 'ReadMessage' -value {
    param([int]$BytesToRead)

    # If we have no bytes to read, do nothing
    if ($BytesToRead -eq 0) {
        return $null;
    }

    [string]$content             = '';
    [SecureString]$SecureContent = $null;
    [int]$TotalMessageSize       = 0;
    # Define our buffer size to ensure we read a certain
    # amount of bytes each read attempt only
    [int]$BufferSize             = 1024;
    # If we read the message and don't know if there is a content available
    # we have to read until we reach EOF. In case we have the exact size
    # of the content, we can read the possible rest
    [bool]$IsSizeKnown           = $FALSE;

    # This will allow us to read a fixed amount of data from our
    # stream and terminate the operation afterwards
    if ($BytesToRead -gt 0) {
        $BufferSize  = $BytesToRead;
        $IsSizeKnown = $TRUE;
    }

    $Icinga2.Log.Write(
        $Icinga2.Enums.LogState.Debug,
        'Reading new message from TCP NetworkStream of Client'
    );

    # Handle errors while reading the SSL Stream
    try {
        # Read the stream as long as we receive data from it
        while ($true) {

            # Create a new byte array with a fixed buffer size
            [byte[]]$bytes = New-Object byte[] $BufferSize;

            # Read the actual data from the stream
            $bytesRead         = $this.sslstream.Read($bytes, 0, $bytes.Length);
            $TotalMessageSize += $bytesRead;

            $Icinga2.Log.Write(
                $Icinga2.Enums.LogState.Debug,
                [string]::Format(
                    'Reading {0} bytes from TCP connection',
                    $bytesRead
                )
            );

            # Build a output message from our received as string and perform
            # possible required cleanup in addition
            if ($bytesRead -ne 0) {
                [string]$message = [System.Text.Encoding]::UTF8.GetString($bytes);

                # In case we receive a larger message, append the message content
                # to our string value
                $content = -Join(
                    $content,
                    $message
                );

                # Ensure our output string is always matching the correct length
                # but only apply this in case we are unsure about the real length
                if ($IsSizeKnown -eq $FALSE) {
                    $content = $content.Substring(
                        0,
                        $TotalMessageSize
                    );
                }

                # EOF reached or the amount of bytes to read was known
                # and we should abort here
                if ($content.Contains("`r`n`r`n") -Or $IsSizeKnown) {
                    break;
                }
            } else {
                break;
            }
        }
    } catch {
        # Might be good too remove this, as errors will occure very likely in case the SSLStream
        # timed out after 2 seconds because no new data have been received.
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Exception,
            [string]::Format(
                'Failed to read Message from stream: {0}',
                $_.Exception.Message
            )
        );

        return $null;
    }

    $Icinga2.Log.Write(
        $Icinga2.Enums.LogState.Debug,
        [string]::Format(
            'Finished reading {0} bytes from current NetworkMessage',
            $TotalMessageSize
        )
    );

    # In case we read no message from the stream, we should do nothing
    if ($TotalMessageSize -eq 0) {
        return $null;
    }

    $SecureContent = $Icinga2.Utils.SecureString.ConvertTo($content);
    $content       = $null;

    return $SecureContent;
}

$NetworkProtocol | Add-Member -membertype ScriptMethod -name 'WriteMessage' -value {
    param($message);

    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($message);
        $Client.SendBufferSize = $bytes.Length;
        $this.sslstream.Write($bytes, 0, $bytes.Length);
        $this.sslstream.Flush();
    } catch {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Exception,
            'Failed to write message into data stream'
        );
    }
}

return $NetworkProtocol;