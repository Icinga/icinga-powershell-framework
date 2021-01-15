function Write-IcingaAgentZonesConfig()
{
    param(
        [array]$Endpoints           = @(),
        [array]$EndpointConnections = @(),
        [string]$ParentZone         = '',
        [array]$GlobalZones         = @(),
        [string]$Hostname           = ''
    );

    if ($Endpoints.Count -eq 0) {
        throw 'Please properly specify your endpoint names';
    }

    if ([string]::IsNullOrEmpty($ParentZone)) {
        throw 'Please specify a parent zone this agent shall connect to / receives connections from';
    }

    if ([string]::IsNullOrEmpty($Hostname)) {
        throw 'Please specify hostname for this agent configuration';
    }

    [int]$Index        = 0;
    [string]$ZonesConf = '';

    $ZonesConf = [string]::Format('{0}object Endpoint "{1}" {2}{3}', $ZonesConf, $Hostname, '{', "`r`n");
    $ZonesConf = [string]::Format('{0}{1}{2}{2}', $ZonesConf, '}', "`r`n");

    foreach ($endpoint in $Endpoints) {
        $ZonesConf = [string]::Format('{0}object Endpoint "{1}" {2}{3}', $ZonesConf, $endpoint, '{', "`r`n");
        if ($EndpointConnections.Count -ne 0) {
            $ConnectionConfig = Get-IPConfigFromString -IPConfig ($EndpointConnections[$Index]);
            $ZonesConf = [string]::Format('{0}    host = "{1}";{2}', $ZonesConf, $ConnectionConfig.address, "`r`n");
            if ([string]::IsNullOrEmpty($ConnectionConfig.port) -eq $FALSE) {
                $ZonesConf = [string]::Format('{0}    port = "{1}";{2}', $ZonesConf, $ConnectionConfig.port, "`r`n");
            }
        }
        $ZonesConf = [string]::Format('{0}{1}{2}{2}', $ZonesConf, '}', "`r`n");
        $Index += 1;
    }

    [string]$EndpointString = '';
    foreach ($endpoint in $Endpoints) {
        $EndpointString = [string]::Format(
            '{0}"{1}", ',
            $EndpointString,
            $endpoint
        );
    }
    $EndpointString = $EndpointString.Substring(0, $EndpointString.Length - 2);

    $ZonesConf = [string]::Format('{0}object Zone "{1}" {2}{3}', $ZonesConf, $ParentZone, '{', "`r`n");
    $ZonesConf = [string]::Format('{0}    endpoints = [ {1} ];{2}', $ZonesConf, $EndpointString, "`r`n");
    $ZonesConf = [string]::Format('{0}{1}{2}{2}', $ZonesConf, '}', "`r`n");

    $ZonesConf = [string]::Format('{0}object Zone "{1}" {2}{3}', $ZonesConf, $Hostname, '{', "`r`n");
    $ZonesConf = [string]::Format('{0}    parent = "{1}";{2}', $ZonesConf, $ParentZone, "`r`n");
    $ZonesConf = [string]::Format('{0}    endpoints = [ "{1}" ];{2}', $ZonesConf, $Hostname, "`r`n");
    $ZonesConf = [string]::Format('{0}{1}{2}{2}', $ZonesConf, '}', "`r`n");

    foreach ($zone in $GlobalZones) {
        $ZonesConf = [string]::Format('{0}object Zone "{1}" {2}{3}', $ZonesConf, $zone, '{', "`r`n");
        $ZonesConf = [string]::Format('{0}    global = true;{1}', $ZonesConf, "`r`n");
        $ZonesConf = [string]::Format('{0}{1}{2}{2}', $ZonesConf, '}', "`r`n");
    }

    $ZonesConf = $ZonesConf.Substring(0, $ZonesConf.Length - 4);

    Set-Content -Path (Join-Path -Path (Get-IcingaAgentConfigDirectory) -ChildPath 'zones.conf') -Value $ZonesConf;
    Write-IcingaConsoleNotice 'Icinga Agent zones.conf has been written successfully';
}
