function Get-IcingaDirectorSelfServiceTicket()
{
    param(
        $DirectorUrl,
        $ApiKey      = $null
    );

    if ([string]::IsNullOrEmpty($DirectorUrl)) {
        Write-Host 'Unable to fetch host ticket. No Director url has been specified';
        return;
    }

    if ([string]::IsNullOrEmpty($ApiKey)) {
        Write-Host 'Unable to fetch host ticket. No API key has been specified';
        return;
    }

    [string]$url = Join-WebPath -Path $DirectorUrl -ChildPath ([string]::Format('/self-service/ticket?key={0}', $ApiKey));

    $response = Invoke-WebRequest -Uri $url -UseBasicParsing -Headers @{ 'accept' = 'application/json'; 'X-Director-Accept' = 'application/json' } -Method 'POST';

    if ($response.StatusCode -ne 200) {
        throw $response.Content;
    }

    $JsonContent = ConvertFrom-Json -InputObject $response.Content;

    return $JsonContent;
}
