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

    $response = Invoke-IcingaWebRequest -Uri $EndpointUrl -UseBasicParsing -Headers @{ 'accept' = 'application/json'; 'X-Director-Accept' = 'application/json' } -Method 'POST' -NoErrorMessage;

    if ($response.StatusCode -ne 200) {
        $ErrorMessage = '';
        switch ($response.StatusCode) {
            403 {
                $ErrorMessage = 'Failed to fetch configuration for host over Self-Service API with key "{0}". This error mostly occurs in case the host object itself is not defined as "Icinga2 Agent" object inside the Icinga Director.';
                break;
            };
            404 {
                $ErrorMessage = 'Failed to fetch configuration for host over Self-Service API with key "{0}". Probably the assigned host/template key is not valid or your Icinga Director Url is invalid "{1}".';
                break;
            };
            901 {
                $ErrorMessage = 'Failed to fetch host/template configuration from Icinga Director Self-Service API because of SSL/TLS error. Please ensure the certificate is valid and use "Enable-IcingaUntrustedCertificateValidation" for self-signed certificates or install the certificate on this machine.';
                break;
            }
            Default {
                $ErrorMessage = ([string]::Format('Failed to fetch host/template configuration from Icinga Director Self-Service API because of unhandled exception: {0}', $response.StatusCode));
                break;
            };
        }

        Write-IcingaConsoleError $ErrorMessage -Objects $ApiKey, $DirectorUrl;
        throw $ErrorMessage;
    }

    $JsonContent = ConvertFrom-Json -InputObject $response.Content;

    if (Test-PSCustomObjectMember -PSObject $JsonContent -Name 'error') {
        throw 'Icinga Director Self-Service has thrown an error: ' + $JsonContent.error;
    }

    $JsonContent = Add-PSCustomObjectMember -Object $JsonContent -Key 'IcingaMaster' -Value $response.BaseResponse.ResponseUri.Host;

    return $JsonContent;
}
