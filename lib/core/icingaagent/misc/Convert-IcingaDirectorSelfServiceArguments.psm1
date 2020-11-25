function Convert-IcingaDirectorSelfServiceArguments()
{
    param(
        $JsonInput
    );

    if ($null -eq $JsonInput) {
        return @{};
    }

    [hashtable]$DirectorArguments = @{
        PackageSource           = $JsonInput.download_url;
        AgentVersion            = $JsonInput.agent_version;
        CAPort                  = $JsonInput.agent_listen_port;
        AllowVersionChanges     = $JsonInput.allow_updates;
        GlobalZones             = $JsonInput.global_zones;
        ParentZone              = $JsonInput.parent_zone;
        #CAEndpoint             = $JsonInput.ca_server;
        Endpoints               = $JsonInput.parent_endpoints;
        AddFirewallRule         = $JsonInput.agent_add_firewall_rule;
        AcceptConnections       = $JsonInput.agent_add_firewall_rule;
        ServiceUser             = $JsonInput.icinga_service_user;
        IcingaMaster            = $JsonInput.IcingaMaster;
        InstallFrameworkService = $JsonInput.install_framework_service;
        ServiceDirectory        = $JsonInput.framework_service_directory;
        FrameworkServiceUrl     = $JsonInput.framework_service_url;
        InstallFrameworkPlugins = $JsonInput.install_framework_plugins;
        PluginsUrl              = $JsonInput.framework_plugins_url;
        ConvertEndpointIPConfig = $JsonInput.resolve_parent_host;
        UpdateAgent             = $TRUE;
        AddDirectorGlobal       = $FALSE;
        AddGlobalTemplates      = $FALSE;
        RunInstaller            = $TRUE;
    };

    # Use NetworkService as default if nothing was transmitted by Director
    if ([string]::IsNullOrEmpty($DirectorArguments['ServiceUser'])) {
        $DirectorArguments['ServiceUser'] = 'NT Authority\NetworkService';
    }

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
        $NetworkDefault = $NetworkDefault.Substring(0, $NetworkDefault.Length - 1).Split(',');
        $DirectorArguments.Add(
            'EndpointConnections', $NetworkDefault
        );

        $EndpointConnections = $NetworkDefault;
        $DirectorArguments.Add(
            'CAEndpoint', (Get-IPConfigFromString $EndpointConnections[0]).address
        );
    }

    return $DirectorArguments;
}
