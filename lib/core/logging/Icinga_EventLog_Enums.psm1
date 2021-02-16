<#
 # This script will provide 'Enums' we can use for proper
 # error handling and to provide more detailed descriptions
 #
 # Example usage:
 # $IcingaEventLogEnums[2000]
 #>
if ($null -eq $IcingaEventLogEnums -Or $IcingaEventLogEnums.ContainsKey('Framework') -eq $FALSE) {
    [hashtable]$IcingaEventLogEnums += @{
        'Framework' = @{
            1000 = @{
                'EntryType' = 'Information';
                'Message'   = 'Generic debug message issued by the Framework or its components';
                'Details'   = 'The Framework or is components can issue generic debug message in case the debug log is enabled. Please ensure to disable it, if not used. You can do so with the command "Disable-IcingaFrameworkDebugMode"';
                'EventId'   = 1000;
            };
            1500 = @{
                'EntryType' = 'Error';
                'Message'   = 'Failed to securely establish a communication between this server and the client';
                'Details'   = 'A client connection could not be established to this server. This issue is mostly caused by using Self-Signed/Icinga 2 Agent certificates for the server and the client not trusting the certificate. To resolve this issue, either use trusted certificates signed by your trusted CA or setup the client to accept untrusted certificates';
                'EventId'   = 1500;
            };
            1501 = @{
                'EntryType' = 'Error';
                'Message'   = 'Client connection was interrupted because of invalid SSL stream';
                'Details'   = 'A client connection was terminated by the Framework because no secure SSL handshake could be established. This issue in general is followed by EventId 1500.';
                'EventId'   = 1501;
            };
            1550 = @{
                'EntryType' = 'Error';
                'Message'   = 'Unsupported web authentication used';
                'Details'   = 'A web client tried to authenticate with an unsupported authorization method.';
                'EventId'   = 1550;
            };
            1551 = @{
                'EntryType' = 'Warning';
                'Message'   = 'Invalid authentication credentials provided';
                'Details'   = 'A web request for a client was rejected because of invalid formated base64 encoded credentials.';
                'EventId'   = 1551;
            };
            1552 = @{
                'EntryType' = 'Error';
                'Message'   = 'Failed to parse use credentials from base64 encoding';
                'Details'   = 'Provided user credentials encoded as base64 could not be converted to domain, user and password objects.';
                'EventId'   = 1552;
            };
            1553 = @{
                'EntryType' = 'Error';
                'Message'   = 'Failed to query Icinga check over internal REST-Api check handler';
                'Details'   = 'A service check could not be executed by using the internal REST-Api check handler. The check either ran into a timeout or could not be processed. Maybe the check was not registered to be allowed for being executed. Further details can be found below.';
                'EventId'   = 1553;
            };
            1560 = @{
                'EntryType' = 'Error';
                'Message'   = 'Failed to test user login as no Principal Context could be established';
                'Details'   = 'A web client trying to authenticate failed as no Principal Context for the provided domain could be established.';
                'EventId'   = 1560;
            };
            1561 = @{
                'EntryType' = 'Error';
                'Message'   = 'Failed to authenticate user with given credentials';
                'Details'   = 'A web client trying to authenticate failed as the provided user credentials could not be verified.';
                'EventId'   = 1561;
            };
        }
    };
}

Export-ModuleMember -Variable @( 'IcingaEventLogEnums' );
