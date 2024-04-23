function New-IcingaForWindowsRESTApi()
{
    # Allow us to parse the framework global data to this thread
    param (
        [string]$Address            = '',
        $Port,
        $CertFile                   = $null,
        $CertThumbprint             = $null,
        [PSCustomObject]$CertFilter = $null,
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

    $Global:Icinga.Public.SSL.CertFile       = $CertFile;
    $Global:Icinga.Public.SSL.CertThumbprint = $CertThumbprint;
    $Global:Icinga.Public.SSL.CertFilter     = $CertFilter;

    while ($TRUE) {
        if ($null -eq $Global:Icinga.Public.SSL.Certificate) {
            $Global:Icinga.Public.SSL.Certificate = Get-IcingaForWindowsCertificate;
        }

        if ($null -ne $Global:Icinga.Public.SSL.Certificate) {
            break;
        }

        # Wait 1 minutes and try again
        Write-IcingaEventMessage -EventId 2002 -Namespace 'RESTApi' -Objects ($Global:Icinga.Public.SSL.Certificate | Out-String), $Global:Icinga.Public.SSL.CertFile, $Global:Icinga.Public.SSL.CertThumbprint, ($Global:Icinga.Public.SSL.CertFilter | Out-String);
        Start-Sleep -Seconds 60;
    }

    # Create a background thread to renew the certificate on a regular basis
    Start-IcingaForWindowsCertificateThreadTask;

    $Socket = New-IcingaTCPSocket -Address $Address -Port $Port -Start;

    # Keep our code executed as long as the PowerShell service is
    # being executed. This is required to ensure we will execute
    # the code frequently instead of only once
    while ($TRUE) {

        # Force Icinga for Windows Garbage Collection
        Optimize-IcingaForWindowsMemory -ClearErrorStack -SmartGC;

        $Connection = Open-IcingaTCPClientConnection `
            -Client (New-IcingaTCPClient -Socket $Socket) `
            -Certificate $Global:Icinga.Public.SSL.Certificate;

        if ($Connection.Client -eq $null -Or $Connection.Stream -eq $null) {
            Close-IcingaTCPConnection -Connection $Connection;
            $Connection = $null;
            continue;
        }

        if (Test-IcingaRESTClientBlacklisted -Client $Connection.Client -ClientList $Global:Icinga.Public.Daemons.RESTApi.ClientBlacklist) {
            Write-IcingaDebugMessage -Message 'A remote client which is trying to connect was blacklisted' -Objects $Connection.Client.Client;
            Close-IcingaTCPConnection -Connection $Connection;
            $Connection = $null;
            continue;
        }

        if ((Test-IcingaRESTClientConnection -Connection $Connection) -eq $FALSE) {
            $Connection = $null;
            continue;
        }

        # API not yet ready
        if ($Global:Icinga.Public.Daemons.RESTApi.ApiRequests.Count -eq 0) {
            Close-IcingaTCPConnection -Connection $Connection;
            $Connection = $null;
            continue;
        }

        try {
            $NextRESTApiThreadId = (Get-IcingaNextRESTApiThreadId);

            Write-IcingaDebugMessage -Message 'Scheduling Icinga for Windows API request' -Objects 'REST-Thread Id', $NextRESTApiThreadId;

            if ($Global:Icinga.Public.Daemons.RESTApi.ApiRequests.ContainsKey($NextRESTApiThreadId) -eq $FALSE) {
                Close-IcingaTCPConnection -Connection $Connection;
                $Connection = $null;
                continue;
            }

            $Global:Icinga.Public.Daemons.RESTApi.ApiRequests.$NextRESTApiThreadId.Add($Connection);
        } catch {
            Write-IcingaEventMessage -Namespace 'RESTApi' -EvenId 2050 -ExceptionObject $_;
        }
    }
}
