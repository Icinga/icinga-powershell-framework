function New-IcingaForWindowsRESTThread()
{
    param (
        $RequireAuth,
        $ThreadId
    );

    # Initialise our performance counter categories
    Show-IcingaPerformanceCounterCategories | Out-Null;

    while ($TRUE) {

        try {
            if ($Global:Icinga.Public.Daemons.RESTApi.ApiRequests.ContainsKey($ThreadId) -eq $FALSE) {
                Start-Sleep -Milliseconds 10;
                continue;
            }

            # block sleeping until content available
            $Connection = $Global:Icinga.Public.Daemons.RESTApi.ApiRequests.$ThreadId.Take();

            # Read the received message from the stream by using our smart functions
            [string]$RestMessage = Read-IcingaTCPStream -Client $Connection.Client -Stream $Connection.Stream;
            # Now properly translate the entire rest message to a parsable hashtable
            $RESTRequest         = Read-IcingaRESTMessage -RestMessage $RestMessage -Connection $Connection;

            if ($null -ne $RESTRequest) {

                # Check if we require to authenticate the user
                if ($RequireAuth) {
                    # If no authentication header is provided we should show the prompt
                    if ([string]::IsNullOrEmpty($RESTRequest.Header.Authorization)) {
                        # In case we do not send an authentication header increase the blacklist counter
                        # to ensure we are not spammed and "attacked" by a client with useless requests
                        Add-IcingaRESTClientBlacklistCount `
                            -Client $Connection.Client `
                            -ClientList $Global:Icinga.Public.Daemons.RESTApi.ClientBlacklist;
                        # Send the authentication prompt
                        Send-IcingaWebAuthMessage -Connection $Connection;
                        # Close the connection
                        Close-IcingaTCPConnection -Client $Connection.Client;
                        $Connection = $null;
                        continue;
                    }

                    $Credentials        = Convert-Base64ToCredentials -AuthString $RESTRequest.Header.Authorization;
                    [bool]$LoginSuccess = Test-IcingaRESTCredentials -UserName $Credentials.user -Password $Credentials.password -Domain $Credentials.domain;
                    $Credentials        = $null;

                    # Handle login failures
                    if ($LoginSuccess -eq $FALSE) {
                        # Failed attempts should increase the blacklist counter
                        Add-IcingaRESTClientBlacklistCount `
                            -Client $Connection.Client `
                            -ClientList $Global:Icinga.Public.Daemons.RESTApi.ClientBlacklist;
                        # Re-send the authentication prompt
                        Send-IcingaWebAuthMessage -Connection $Connection;
                        # Close the connection
                        Close-IcingaTCPConnection -Client $Connection.Client;
                        $Connection = $null;
                        continue;
                    }
                }

                # Set our thread being active
                Set-IcingaForWindowsThreadAlive -ThreadName $Global:Icinga.Protected.ThreadName -Active -TerminateAction @{ 'Command' = 'Close-IcingaTCPConnection'; 'Arguments' = @{ 'Client' = $Connection.Client } };

                # We should remove clients from the blacklist who are sending valid requests
                Remove-IcingaRESTClientBlacklist -Client $Connection.Client -ClientList $Global:Icinga.Public.Daemons.RESTApi.ClientBlacklist;
                switch (Get-IcingaRESTPathElement -Request $RESTRequest -Index 0) {
                    'v1' {
                        Invoke-IcingaRESTAPIv1Calls -Request $RESTRequest -Connection $Connection;
                        break;
                    };
                    default {
                        Write-IcingaDebugMessage -Message ('Invalid API call - no version specified' + ($RESTRequest.RequestPath | Out-String));
                        Send-IcingaTCPClientMessage -Message (
                            New-IcingaTCPClientRESTMessage `
                                -HTTPResponse ($IcingaHTTPEnums.HTTPResponseType.'Not Found') `
                                -ContentBody 'Invalid API call received. No version specified.'
                        ) -Stream $Connection.Stream;
                    };
                }

                # set our thread no longer be active. We do this, because below there is no way we can
                # actually get stuck on a endless loop, caused by external modules
                Set-IcingaForWindowsThreadAlive -ThreadName $Global:Icinga.Protected.ThreadName;
            }
        } catch {
            $ExMsg = $_.Exception.Message;

            Send-IcingaTCPClientMessage -Message (
                            New-IcingaTCPClientRESTMessage `
                                -HTTPResponse ($IcingaHTTPEnums.HTTPResponseType.'Internal Server Error') `
                                -ContentBody $ExMsg
                        ) -Stream $Connection.Stream;

            Write-IcingaEventMessage -Namespace 'RESTApi' -EventId 2051 -ExceptionObject $_;
        }

        # Finally close the clients connection as we are done here and
        # ensure this thread will close by simply leaving the function
        Close-IcingaTCPConnection -Client $Connection.Client;
        $Connection = $null;

        # Force Icinga for Windows Garbage Collection
        Optimize-IcingaForWindowsMemory -ClearErrorStack -SmartGC;
    }
}
