<#
 # This script will provide 'Enums' we can use for proper
 # error handling and to provide more detailed descriptions
 #
 # Example usage:
 # $IcingaEventLogEnums[2000]
 #>
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
            'Message'   = 'Failed to securely establish a communiation between this server and the client';
            'Details'   = 'A client connection could not be established to this server. This issue is mostly caused by using Self-Signed/Icinga 2 Agent certificates for the server and the client not trusting the certificate. To resolve this issue, either use trusted certificates signed by your trusted CA or setup the client to accept untrusted certificates';
            'EventId'   = 1500;
        };
        1501 = @{
            'EntryType' = 'Error';
            'Message'   = 'Client connection was interrupted because of invalid SSL stream';
            'Details'   = 'A client connection was terminated by the Framework because no secure SSL handshake could be established. This issue in general is followed by EventId 1500.';
            'EventId'   = 1501;
        };
    }
};

Export-ModuleMember -Variable @( 'IcingaEventLogEnums' );
