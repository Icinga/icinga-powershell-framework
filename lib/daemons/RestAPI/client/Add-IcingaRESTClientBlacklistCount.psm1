function Add-IcingaRESTClientBlacklistCount()
{
    param (
        [System.Net.Sockets.TcpClient]$Client = $null,
        $ClientList                           = $null
    );

    if ($null -eq $Client) {
        return;
    }

    [string]$Endpoint  = Get-IcingaTCPClientRemoteEndpoint -Client $Client;
    [string]$IpAddress = $Endpoint.Split(':')[0];
    [int]$Value        = Get-IcingaHashtableItem `
                            -Hashtable $ClientList `
                            -Key $IpAddress `
                            -NullValue 0;

    Add-IcingaHashtableItem `
        -Hashtable $ClientList `
        -Key $IpAddress `
        -Value ($Value + 1) `
        -Override | Out-Null;
}
