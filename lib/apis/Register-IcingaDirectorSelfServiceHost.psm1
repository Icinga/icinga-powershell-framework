<#
.SYNOPSIS
   Register the current host within the Icinga Director by using the
   Self-Service API and return the host key
.DESCRIPTION
   This function will register the current host within the Icinga Director in case
   it is not already registered and returns the host key for storing it on disk
   to allow the host to fetch detailed configurations like zones and endpoints
.FUNCTIONALITY
   Register a host within the Icinga Director by using the Self-Service API
.EXAMPLE
   PS>Register-IcingaDirectorSelfServiceHost -DirectorUrl 'https://example.com/icingaweb2/director -Hostname 'examplehost' -ApiKey 457g6b98054v76vb5490ß276bv0457v6054b76 -Endpoint 'icinga.example.com';
.PARAMETER DirectorUrl
   The URL pointing directly to the Icinga Web 2 Director module
.PARAMETER Hostname
   The name of the current host to register within the Icinga Director
.PARAMETER ApiKey
   The template key to authenticate against the Self-Service API
.PARAMETER Endpoint
   The IP or FQDN to one of the parent Icinga 2 nodes this Agent will connect to
   for determining which network interface shall be used by Icinga for connecting
   and to apply hostalive/ping checks to
.INPUTS
   System.String
.OUTPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

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

    Set-IcingaTLSVersion;
    $ProgressPreference = "SilentlyContinue";
    $DirectorConfigJson = $null;

    if ([string]::IsNullOrEmpty($Endpoint)) {
        if ($DirectorUrl.Contains('https://') -Or $DirectorUrl.Contains('http://')) {
            $Endpoint = $DirectorUrl.Split('/')[2];
        } else {
            $Endpoint = $DirectorUrl.Split('/')[0];
        }
    }

    $Interface          = Get-IcingaNetworkInterface $Endpoint;
    $DirectorConfigJson = [string]::Format('{0} "address":"{2}" {1}', '{', '}', $Interface);

    $EndpointUrl = Join-WebPath -Path $DirectorUrl -ChildPath ([string]::Format('/self-service/register-host?name={0}&key={1}', $Hostname, $ApiKey));

    $response = Invoke-IcingaWebRequest -Uri $EndpointUrl -UseBasicParsing -Headers @{ 'accept' = 'application/json'; 'X-Director-Accept' = 'application/json' } -Method 'POST' -Body $DirectorConfigJson -NoErrorMessage;

    if ($response.StatusCode -ne 200) {
        $ErrorMessage = '';
        switch ($response.StatusCode) {
            400 {
                Write-IcingaConsoleWarning 'Failed to register host inside Icinga Director. The host is probably already registered.'
                return $null;
            };
            404 {
                $ErrorMessage = 'Failed to register host with the given API key "{0}" inside Icinga Director. Please ensure the template key you are using is correct and the template is set as "Icinga2 Agent" object. Non-Agent templates will not work over the Self-Service API.';
                break;
            };
            901 {
                $ErrorMessage = 'Failed to register host over Self-Service API inside Icinga Director because of SSL/TLS error. Please ensure the certificate is valid and use "Enable-IcingaUntrustedCertificateValidation" for self-signed certificates or install the certificate on this machine.';
                break;
            }
            Default {
                $ErrorMessage = ([string]::Format('Failed to register host inside Icinga Director because of unhandled exception: {0}', $response.StatusCode));
                break;
            };
        }

        Write-IcingaConsoleError $ErrorMessage -Objects $ApiKey;
        throw $ErrorMessage;
    }

    $JsonContent = ConvertFrom-Json -InputObject $response.Content;

    if (Test-PSCustomObjectMember -PSObject $JsonContent -Name 'error') {
        if ($JsonContent.error -like '*already been registered*') {
            return $null;
        }

        throw 'Icinga Director Self-Service has thrown an error: ' + $JsonContent.error;
    }

    Set-IcingaPowerShellConfig -Path 'IcingaDirector.SelfService.ApiKey' -Value $JsonContent;

    Write-IcingaConsoleNotice 'Host was successfully registered within Icinga Director';

    return $JsonContent;
}
