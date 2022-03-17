function New-IcingaForWindowsRESTApi()
{
    # Allow us to parse the framework global data to this thread
    param (
        [string]$Address  = '',
        $Port,
        $CertFile,
        $CertThumbprint,
        $RequireAuth
    );

    $RESTEndpoints = Invoke-IcingaNamespaceCmdlets -Command 'Register-IcingaRESTAPIEndpoint*';
    Write-IcingaDebugMessage -Message (
        [string]::Format(
            'Loading configuration for REST-Endpoints{0}{1}',
            (New-IcingaNewLine),
            ($RESTEndpoints | Out-String)
        )
    );

    Write-IcingaDebugMessage -Message ($Global:Icinga.Public.Daemons.RESTApi | Out-String);

    foreach ($entry in $RESTEndpoints.Values) {
        [bool]$Success = Add-IcingaHashtableItem `
            -Hashtable $Global:Icinga.Public.Daemons.RESTApi.RegisteredEndpoints `
            -Key $entry.Alias `
            -Value $entry.Command;

        if ($Success -eq $FALSE) {
            Write-IcingaEventMessage `
                -EventId 2100 `
                -Namespace 'RESTApi' `
                -Objects ([string]::Format('Adding duplicated REST endpoint "{0}" with command "{1}', $entry.Alias, $entry.Command)), $RESTEndpoints;
        }
    }

    $CommandAliases = Invoke-IcingaNamespaceCmdlets -Command 'Register-IcingaRESTApiCommandAliases*';

    foreach ($entry in $CommandAliases.Values) {
        foreach ($component in $entry.Keys) {
            [bool]$Success = Add-IcingaHashtableItem `
                -Hashtable $Global:Icinga.Public.Daemons.RESTApi.CommandAliases `
                -Key $component `
                -Value $entry[$component];

            if ($Success -eq $FALSE) {
                Write-IcingaEventMessage `
                    -EventId 2101 `
                    -Namespace 'RESTApi' `
                    -Objects ([string]::Format('Adding duplicated REST command aliases "{0}" for namespace "{1}', $entry[$component], $component)), $CommandAliases;
            }
        }
    }

    Write-IcingaDebugMessage -Message ($Global:Icinga.Public.Daemons.RESTApi.RegisteredEndpoints | Out-String);

    if ($Global:Icinga.Protected.JEAContext) {
        if ($Global:Icinga.Public.ContainsKey('SSLCertificate') -eq $FALSE -Or $null -eq $Global:Icinga.Public.SSLCertificate) {
            Write-IcingaEventMessage -EventId 2001 -Namespace 'RESTApi';
            return;
        }

        $Certificate = $Global:Icinga.Public.SSLCertificate;
    } else {
        $Certificate = Get-IcingaSSLCertForSocket -CertFile $CertFile -CertThumbprint $CertThumbprint;
    }

    if ($null -eq $Certificate) {
        Write-IcingaEventMessage -EventId 2000 -Namespace 'RESTApi';
        return;
    }

    $Socket = New-IcingaTCPSocket -Address $Address -Port $Port -Start;

    # Keep our code executed as long as the PowerShell service is
    # being executed. This is required to ensure we will execute
    # the code frequently instead of only once
    while ($TRUE) {

        # Force Icinga for Windows Garbage Collection
        Optimize-IcingaForWindowsMemory -ClearErrorStack -SmartGC;

        $Connection = Open-IcingaTCPClientConnection `
            -Client (New-IcingaTCPClient -Socket $Socket) `
            -Certificate $Certificate;

        if (Test-IcingaRESTClientBlacklisted -Client $Connection.Client -ClientList $Global:Icinga.Public.Daemons.RESTApi.ClientBlacklist) {
            Write-IcingaDebugMessage -Message 'A remote client which is trying to connect was blacklisted' -Objects $Connection.Client.Client;
            Close-IcingaTCPConnection -Client $Connection.Client;
            continue;
        }

        if ((Test-IcingaRESTClientConnection -Connection $Connection) -eq $FALSE) {
            continue;
        }

        # API not yet ready
        if ($Global:Icinga.Public.Daemons.RESTApi.ApiRequests.Count -eq 0) {
            Close-IcingaTCPConnection -Client $Connection.Client;
            continue;
        }

        try {
            $NextRESTApiThreadId = (Get-IcingaNextRESTApiThreadId);

            if ($Global:Icinga.Public.Daemons.RESTApi.ApiRequests.ContainsKey($NextRESTApiThreadId) -eq $FALSE) {
                Close-IcingaTCPConnection -Client $Connection.Client;
                continue;
            }

            $Global:Icinga.Public.Daemons.RESTApi.ApiRequests.$NextRESTApiThreadId.Add($Connection);
        } catch {
            Write-IcingaEventMessage -Namespace 'RESTApi' -EvenId 2050 -ExceptionObject $_;
        }
    }
}
