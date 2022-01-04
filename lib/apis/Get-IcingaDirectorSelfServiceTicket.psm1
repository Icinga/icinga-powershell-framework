<#
.SYNOPSIS
    Will fetch the ticket for certificate signing by using the Icinga Director
    Self-Service API
.DESCRIPTION
    Use the Self-Service API of the Icinga Director to connect to it and fetch the
    ticket to sign Icinga 2 certificate requests
.FUNCTIONALITY
    Fetches the ticket for certificate signing form the Icinga Director Self-Service API
.EXAMPLE
    PS>Get-IcingaDirectorSelfServiceTicket -DirectorUrl 'https://example.com/icingaweb2/director -ApiKey 457g6b98054v76vb5490ß276bv0457v6054b76;
.PARAMETER DirectorUrl
    The URL pointing directly to the Icinga Web 2 Director module
.PARAMETER ApiKey
    The host key to authenticate against the Self-Service API
.INPUTS
    System.String
.OUTPUTS
    System.Object
.LINK
    https://github.com/Icinga/icinga-powershell-framework
#>

function Get-IcingaDirectorSelfServiceTicket()
{
    param (
        $DirectorUrl,
        $ApiKey      = $null
    );

    if ([string]::IsNullOrEmpty($DirectorUrl)) {
        Write-IcingaConsoleError 'Unable to fetch host ticket. No Director url has been specified';
        return;
    }

    if ([string]::IsNullOrEmpty($ApiKey)) {
        Write-IcingaConsoleError 'Unable to fetch host ticket. No API key has been specified';
        return;
    }

    Set-IcingaTLSVersion;

    [string]$url = Join-WebPath -Path $DirectorUrl -ChildPath ([string]::Format('/self-service/ticket?key={0}', $ApiKey));

    $response = Invoke-IcingaWebRequest -Uri $url -UseBasicParsing -Headers @{ 'accept' = 'application/json'; 'X-Director-Accept' = 'application/json' } -Method 'POST' -NoErrorMessage;

    if ($response.StatusCode -ne 200) {
        $ErrorMessage = '';
        switch ($response.StatusCode) {
            404 {
                $ErrorMessage = ([string]::Format('Failed to fetch certificate ticket for this host over Self-Service API. Please check that your Icinga Director Url "{1}" is valid and the provided API key "{0}" belongs to a Icinga host object.', $DirectorUrl, $ApiKey));
                break;
            };
            500 {
                $ErrorMessage = 'Failed to fetch certificate ticket for this host over Self-Service API. Please check that your Icinga CA is running, you have configured a Ticketsalt and that your Icinga Director has enough permissions to communicate with the Icinga 2 API for generating tickets.';
                break;
            };
            901 {
                $ErrorMessage = 'Failed to fetch certificate ticket for this host over Self-Service API because of SSL/TLS error. Please ensure the certificate is valid and use "Enable-IcingaUntrustedCertificateValidation" for self-signed certificates or install the certificate on this machine.';
                break;
            }
            Default {
                $ErrorMessage = ([string]::Format('Failed to fetch certificate ticket from Icinga Director because of unhandled exception: {0}', $response.StatusCode));
                break;
            };
        }

        Write-IcingaConsoleError $ErrorMessage -Objects $ApiKey, $DirectorUrl;
        throw $ErrorMessage;
    }

    $JsonContent = ConvertFrom-Json -InputObject $response.Content;

    return $JsonContent;
}
