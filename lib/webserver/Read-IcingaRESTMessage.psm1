function Read-IcingaRESTMessage()
{
    param(
        [string]$RestMessage   = $null,
        [hashtable]$Connection = $null
    );

    # Just in case we didn't receive anything - no need to
    # parse through everything
    if ([string]::IsNullOrEmpty($RestMessage)) {
        return $null;
    }

    Write-IcingaDebugMessage (
        [string]::Format(
            'Receiving client message{0}{0}{1}',
            (New-IcingaNewLine),
            $RestMessage
        )
    );

    [hashtable]$Request = @{ };
    $RestMessage -match '(.+) (.+) (.+)' | Out-Null;

    $Request.Add('Method', $Matches[1]);
    $Request.Add('FullRequest', $Matches[2]);
    $Request.Add('RequestPath', @{ });
    $Request.Add('RequestArguments', @{ });

    #Path
    $PathMatch = $Matches[2];
    $PathMatch -match '((\/[^\/\?]+)*)\??([^\/]*)' | Out-Null;
    $Arguments = $Matches[3];
    $Request.RequestPath.Add('FullPath', $Matches[1]);
    $Request.RequestPath.Add('PathArray', $Matches[1].TrimStart('/').Split('/'));

    $Matches = $null;

    # Arguments
    $ArgumentsSplit = $Arguments.Split('&');
    $ArgumentsSplit+='\\\\\\\\\\\\=FIN';
    foreach ( $Argument in $ArgumentsSplit | Sort-Object -Descending) {
        if ($Argument.Contains('=')) {
            $Argument -match '(.+)=(.+)' | Out-Null;
            If (($Matches[1] -ne $Current) -And ($NULL -ne $Current)) {
                $Request.RequestArguments.Add( $Current, $ArgumentContent );
                [array]$ArgumentContent = $null;
            }
            $Current = $Matches[1];
            [array]$ArgumentContent += ($Matches[2]);
        } else {
            $Request.RequestArguments.Add( $Argument, $null );
        }
    }

    # Header
    $Request.Add( 'Header', @{ } );
    $SplitString = $RestMessage.Split("`r`n");

    foreach ( $SingleString in $SplitString ) {
        if ( ([string]::IsNullOrEmpty($SingleString) -eq $FALSE) -And ($SingleString -match '^{.+' -eq $FALSE) -And $SingleString.Contains(':') -eq $TRUE ) {
            $SingleSplitString = $SingleString.Split(':', 2);
            $Request.Header.Add( $SingleSplitString[0], $SingleSplitString[1].Trim());
        }
    }

    $Request.Add('ContentLength', [int](Get-IcingaRESTHeaderValue -Header 'Content-Length' -Request $Request));

    $Matches = $null;

    # Body
    $RestMessage -match '(\{(.*\n)*}|\{.*\})' | Out-Null;

    if ($null -ne $Matches) {
        $Request.Add('Body', $Matches[1]);
    }

    # We received a content length, but couldn't load the body. Some clients will send the body as separate message
    # Lets try to read the body content
    if ($null -ne $Connection) {
        if ($Request.ContainsKey('ContentLength') -And $Request.ContentLength -gt 0 -And ($Request.ContainsKey('Body') -eq $FALSE -Or [string]::IsNullOrEmpty($Request.Body))) {
            $Request.Body = Read-IcingaTCPStream -Client $Connection.Client -Stream $Connection.Stream -ReadLength $Request.ContentLength;
            Write-IcingaDebugMessage -Message 'Body Content' -Objects $Request;
        }
    }

    return $Request;
}
