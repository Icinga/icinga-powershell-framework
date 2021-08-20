function New-IcingaTCPClientRESTMessage()
{
    param(
        [Hashtable]$Headers = $null,
        $ContentBody        = $null,
        [int]$HTTPResponse  = 200,
        [switch]$BasicAuth  = $FALSE
    );

    [string]$ContentLength = '';
    [string]$HTMLContent   = '';
    [string]$AuthHeader    = '';

    if ($null -ne $ContentBody) {
        $json         = ConvertTo-Json $ContentBody -Depth 100 -Compress;
        $bytes        = [System.Text.Encoding]::UTF8.GetBytes($json);
        $HTMLContent  = [System.Text.Encoding]::UTF8.GetString($bytes);
        if ($bytes.Length -gt 0) {
            $ContentLength = [string]::Format(
                'Content-Length: {0}{1}',
                $bytes.Length,
                (New-IcingaNewLine)
            );
        }
    }

    if ($BasicAuth) {
        $AuthHeader = [string]::Format(
            'WWW-Authenticate: Basic realm="Icinga for Windows"{0}',
            (New-IcingaNewLine)
        );
    }

    $ResponseMessage = -Join(
        [string]::Format(
            'HTTP/1.1 {0} {1}{2}',
            $HTTPResponse,
            $IcingaHTTPEnums.HTTPResponseCode[$HTTPResponse],
            (New-IcingaNewLine)
        ),
        [string]::Format(
            'Server: {0}{1}',
            (Get-IcingaHostname -LowerCase $TRUE -AutoUseFQDN $TRUE),
            (New-IcingaNewLine)
        ),
        [string]::Format(
            'Content-Type: application/json{0}',
            (New-IcingaNewLine)
        ),
        $AuthHeader,
        $ContentLength,
        (New-IcingaNewLine),
        $HTMLContent
    );

    Write-IcingaDebugMessage -Message 'Sending message to client' -Objects $ResponseMessage;

    # Encode our message before sending it
    $UTF8Message = [System.Text.Encoding]::UTF8.GetBytes($ResponseMessage);

    return @{
        'message' = $UTF8Message;
        'length'  = $UTF8Message.Length;
    };
}
