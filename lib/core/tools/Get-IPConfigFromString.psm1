function Get-IPConfigFromString()
{
    param(
        [string]$IPConfig
    );

    if ($IPConfig.Contains(':') -and ($IPConfig.Contains('[') -eq $FALSE -And $IPConfig.Contains(']') -eq $FALSE)) {
        throw 'Invalid IP-Address format. For IPv6 and/or port configuration, the syntax must be like [ip]:port';
    }

    if ($IPConfig.Contains('[') -eq $FALSE) {
        return @{
            'address' = $IPConfig;
            'port'    = $null
        };
    }

    if ($IPConfig.Contains('[') -eq $FALSE -or $IPConfig.Contains(']') -eq $FALSE) {
        throw 'Invalid IP-Address format. It must match the following [ip]:port';
    }

    $StartBracket  = $IPConfig.IndexOf('[') + 1;
    $EndBracket    = $IPConfig.IndexOf(']') - 1;
    $PortDelimeter = $IPConfig.LastIndexOf(':') + 1;

    $Port = '';
    $IP   = $IPConfig.Substring($StartBracket, $EndBracket);

    if ($PortDelimeter -ne 0 -And $PortDelimeter -ge $EndBracket) {
        $Port = $IPConfig.Substring($PortDelimeter, $IPConfig.Length - $PortDelimeter);
    }

    return @{
        'address' = $IP;
        'port'    = $Port
    };
}
