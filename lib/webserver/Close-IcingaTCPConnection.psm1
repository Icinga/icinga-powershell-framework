function Close-IcingaTCPConnection()
{
    param(
        [hashtable]$Connection = @{ }
    );

    if ($null -eq $Connection -Or $Connection.Count -eq 0) {
        $Connection = $null;

        return;
    }

    Write-IcingaDebugMessage -Message (
        [string]::Format(
            'Closing client connection for endpoint {0}',
            (Get-IcingaTCPClientRemoteEndpoint -Client $Connection.Client)
        )
    );

    try {
        if ($null -ne $Connection.Stream) {
            $Connection.Stream.Close();
            $Connection.Stream.Dispose();
            $Connection.Stream = $null;
        }
    } catch {
        $Connection.Stream = $null;
    }
    try {
        if ($null -ne $Connection.Client) {
            $Connection.Client.Close();
            $Connection.Client.Dispose();
            $Connection.Client = $null;
        }
    } catch {
        $Connection.Client = $null;
    }

    $Connection = $null;
}
