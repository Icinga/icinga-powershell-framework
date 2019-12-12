function Register-IcingaDirectorSelfServiceHost()
{
    param(
        $DirectorUrl,
        $Hostname,
        $ApiKey           = $null,
        [string]$Endpoint = $null
    );

    if ([string]::IsNullOrEmpty($DirectorUrl)) {
        throw 'Please enter a valid Url to your Icinga Director';
    }

    if ([string]::IsNullOrEmpty($Hostname)) {
        throw 'Please enter the hostname to use';
    }

    if ([string]::IsNullOrEmpty($ApiKey)) {
        throw 'Please enter the API key of the template you wish to use';
    }

    $ProgressPreference = "SilentlyContinue";
    $DirectorConfigJson = $null;

    if ([string]::IsNullOrEmpty($Endpoint) -eq $FALSE) {
        $Interface          = Get-IcingaNetworkInterface $Endpoint;
        $DirectorConfigJson = [string]::Format('{0} "address":"{2}" {1}', '{', '}', $Interface);
    }

    $EndpointUrl = Join-WebPath -Path $DirectorUrl -ChildPath ([string]::Format('/self-service/register-host?name={0}&key={1}', $Hostname, $ApiKey));

    $response = Invoke-WebRequest -Uri $EndpointUrl -UseBasicParsing -Headers @{ 'accept' = 'application/json'; 'X-Director-Accept' = 'application/json' } -Method 'POST' -Body $DirectorConfigJson;

    if ($response.StatusCode -ne 200) {
        throw $response.Content;
    }

    $JsonContent = ConvertFrom-Json -InputObject $response.Content;

    if (Test-PSCustomObjectMember -PSObject $JsonContent -Name 'error') {
        if ($JsonContent.error -like '*already been registered*') {
            return $null;
        }

        throw 'Icinga Director Self-Service has thrown an error: ' + $JsonContent.error;
    }

    Set-IcingaPowerShellConfig -Path 'IcingaDirector.SelfService.ApiKey' -Value $JsonContent;

    Write-Host 'Host was successfully registered within Icinga Director';

    return $JsonContent;
}
