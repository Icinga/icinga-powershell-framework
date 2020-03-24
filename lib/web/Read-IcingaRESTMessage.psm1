function Read-IcingaRESTMessage()
{
    param(
        [string]$RestMessage = $null
    );

    [hashtable]$Request = @{};
    $RestMessage -match '(\d+) (.+) (.+) (.+)' | Out-Null;
 
    $Request.Add('MessageLength', $Matches[1]);
    $Request.Add('Method', $Matches[2]);
    $Request.Add('FullRequest', $Matches[3]);
    $Request.Add('RequestPath', @{});
    $Request.Add('RequestArguments', @{});

    #Path
    $PathMatch = $Matches[3];
    $PathMatch -match '(.+)\?(.*)' | Out-Null;
    $Arguments = $Matches[2];
    $Request.RequestPath.Add('FullPath', $Matches[1]);
    $Request.RequestPath.Add('PathArray', $Matches[1].TrimStart('/').Split('/'));

    $Matches = $null;

    # Arguments
    $ArgumentsSplit = $Arguments.Split('&');
    $ArgumentsSplit+='\\\\\\\\\\\\=FIN';
    foreach ( $Argument in $ArgumentsSplit | Sort-Object -descending) {
        $Argument -match '(.+)=(.+)' | Out-Null;
        If (($Matches[1] -ne $Current) -And ($NULL -ne $Current)) {
            $Request.RequestArguments.Add( $Current, $ArgumentContent );
            [array]$ArgumentContent = $null;
        }
        $Current = $Matches[1];
        [array]$ArgumentContent += ($Matches[2]);
    }

    # Header
    $Request.Add( 'Header', @{} );
    $SplitString = $RestMessage.split("`r`n");
    foreach ( $SingleString in $SplitString ) {
        if ( ([string]::IsNullOrEmpty($SingleString) -eq $FALSE) -And ($SingleString -match '^{.+' -eq $FALSE) ) {
            $SingleSplitString = $SingleString.Split(':',2);
            $Request.Header.Add( $SingleSplitString[0], $SingleSplitString[1].Trim());
        }
    }

    $Request.Add('ContentLength', [int](Get-IcingaRESTHeaderValue -Header 'Content-Length' -Request $Request));

    $Matches = $null;

    # Body
    $RestMessage -match '(\{(.*\n)*}|\{.*\})' | Out-Null;
    $Request.Add('Body', $Matches[1]);

    return $Request;
}
