<#
.SYNOPSIS
   Will fetch the current host configuration or general configuration depending
   if a host or template key is specified from the Icinga Director Self-Service API
.DESCRIPTION
   Use the Self-Service API of the Icinga Director to connect to it and fetch the
   configuration to apply for this host. The configuration itself is differentiated
   if a template or the specific host key is used
.FUNCTIONALITY
   Fetches host or general configuration form the Icinga Director Self-Service API
.EXAMPLE
   PS>Get-IcingaDirectorSelfServiceConfig -DirectorUrl 'https://example.com/icingaweb2/director -ApiKey 457g6b98054v76vb5490ß276bv0457v6054b76;
.PARAMETER DirectorUrl
   The URL pointing directly to the Icinga Web 2 Director module
.PARAMETER ApiKey
   Either the template or host key to authenticate against the Self-Service API
.INPUTS
   System.String
.OUTPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

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
        throw 'Please enter either a template or your host key. If this message persists, ensure your host is not having a template key assigned already. If so, you can try dropping it within the Icinga Director.';
    }

    Set-IcingaTLSVersion;
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

    $JsonContent = Add-PSCustomObjectMember -Object $JsonContent -Key 'IcingaMaster' -Value $response.BaseResponse.ResponseUri.Host;

    return $JsonContent;
}
