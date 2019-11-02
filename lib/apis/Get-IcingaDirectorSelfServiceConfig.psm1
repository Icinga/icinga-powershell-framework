function Get-IcingaDirectorSelfServiceConfig()
{
    param(
        $DirectorUrl,
        $ApiKey      = $null
    );

    if ([string]::IsNullOrEmpty($DirectorUrl)) {
        throw 'Please enter a valid Url to your Icinga Director';
    }

    if ([string]::IsNullOrEmpty($ApiKey)) {
        throw 'Please enter either a template or your host key';
    }

    $ProgressPreference = "SilentlyContinue";

    $EndpointUrl = Join-WebPath -Path $DirectorUrl -ChildPath ([string]::Format('/self-service/powershell-parameters?key={0}', $ApiKey));

    $response = Invoke-WebRequest -Uri $EndpointUrl -UseBasicParsing -Headers @{ 'accept' = 'application/json'; 'X-Director-Accept' = 'application/json' } -Method 'POST';

    if ($response.StatusCode -ne 200) {
        throw $response.Content;
    }

    $JsonContent = ConvertFrom-Json -InputObject $response.Content;

    if (Test-PSCustomObjectMember -PSObject $JsonContent -Name 'error') {
        throw 'Icinga Director Self-Service has thrown an error: ' + $JsonContent.error;
    }

    return $JsonContent;
}
