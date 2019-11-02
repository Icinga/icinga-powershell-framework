function Convert-IcingaDirectorSelfServiceArguments()
{
    param(
        $JsonInput
    );

    if ($null -eq $JsonInput) {
        return @{};
    }

    [hashtable]$DirectorArguments = @{
        PackageSource       = $JsonInput.download_url;
        AgentVersion        = $JsonInput.agent_version;
        CAPort              = $JsonInput.agent_listen_port;
        AllowVersionChanges = $JsonInput.allow_updates;
        GlobalZones         = $JsonInput.global_zones;
        ParentZone          = $JsonInput.parent_zone;
        CAEndpoint          = $JsonInput.ca_server;
        Endpoints           = $JsonInput.parent_endpoints;
        AddFirewallRule     = $JsonInput.agent_add_firewall_rule;
        AcceptConnections   = $JsonInput.agent_add_firewall_rule;
        #ServiceUser         = $JsonInput.service_user; # This is yet missing within the Icinga Director API
        ServiceUser         = 'NT Authority\NetworkService';
        UpdateAgent         = $TRUE;
        AddDirectorGlobal   = $FALSE;
        AddGlobalTemplates  = $FALSE;
        RunInstaller        = $TRUE;
    };

    if ($JsonInput.transform_hostname -eq 1) {
        $DirectorArguments.Add(
            'LowerCase', $TRUE
        );
    }

    if ($JsonInput.transform_hostname -eq 2) {
        $DirectorArguments.Add(
            'UpperCase', $TRUE
        );
    }

    if ($JsonInput.fetch_agent_fqdn) {
        $DirectorArguments.Add(
            'AutoUseFQDN', $TRUE
        );
    } elseif ($JsonInput.fetch_agent_name) {
        $DirectorArguments.Add(
            'AutoUseHostname', $TRUE
        );
    }

    $NetworkDefault = '';
    foreach ($Endpoint in $JsonInput.parent_endpoints) {
        $NetworkDefault += [string]::Format('[{0}]:{1},', $Endpoint, $JsonInput.agent_listen_port);
    }
    if ([string]::IsNullOrEmpty($NetworkDefault) -eq $FALSE) {
        $NetworkDefault = $NetworkDefault.Substring(0, $NetworkDefault.Length - 1);
        $DirectorArguments.Add(
            'EndpointConnections', $NetworkDefault
        );
    }

    return $DirectorArguments;
}
