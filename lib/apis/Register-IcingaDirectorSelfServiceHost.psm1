<#
.SYNOPSIS
   Register the current host wihtin the Icinga Director by using the
   Self-Service API and return the host key
.DESCRIPTION
   This function will register the current host within the Icinga Director in case
   it is not already registered and returns the host key for storing it on disk
   to allow the host to fetch detailed configurations like zones and endppoints
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

    if ([string]::IsNullOrEmpty($Endpoint) -eq $FALSE) {
        $Interface          = Get-IcingaNetworkInterface $Endpoint;
        $DirectorConfigJson = [string]::Format('{0} "address":"{2}" {1}', '{', '}', $Interface);
    }

    $EndpointUrl = Join-WebPath -Path $DirectorUrl -ChildPath ([string]::Format('/self-service/register-host?name={0}&key={1}', $Hostname, $ApiKey));

    $response = Invoke-IcingaWebRequest -Uri $EndpointUrl -UseBasicParsing -Headers @{ 'accept' = 'application/json'; 'X-Director-Accept' = 'application/json' } -Method 'POST' -Body $DirectorConfigJson;

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

    Write-IcingaConsoleNotice 'Host was successfully registered within Icinga Director';

    return $JsonContent;
}
