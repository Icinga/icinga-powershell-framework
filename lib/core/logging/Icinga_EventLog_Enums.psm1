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
            1001 = @{
                'EntryType' = 'Warning';
                'Message'   = 'Icinga for Windows deprecation warning';
                'Details'   = 'Icinga for Windows or one of its components executed a function or method, which is flagged as deprecated. Please modify your code or contact the responsible developer to update the component to no longer user this deprecated function or method.';
                'EventId'   = 1001;
            };
            1100 = @{
                'EntryType' = 'Error';
                'Message'   = 'Corrupt Icinga for Windows configuration';
                'Details'   = 'Your Icinga for Windows configuration file was corrupt and could not be read successfully. A new configuration file was created and the old one renamed for review, to keep your settings available.';
                'EventId'   = 1100;
            };
            1101 = @{
                'EntryType' = 'Warning';
                'Message'   = 'Unable to update Icinga for Windows file';
                'Details'   = 'Icinga for Windows could not update the specified file after several attempts, because another process is locking it. Modifications made on the file have not been persisted.';
                'EventId'   = 1101;
            };
            1102 = @{
                'EntryType' = 'Warning';
                'Message'   = 'Unable to read Icinga for Windows content file';
                'Details'   = 'Icinga for Windows could not read the specified file after several attempts, because another process is locking the file. Icinga for Windows terminated itself to prevent damage to this file.';
                'EventId'   = 1102;
            };
            1103 = @{
                'EntryType' = 'Error';
                'Message'   = 'Failed to load Icinga for Windows namespace content';
                'Details'   = 'Icinga for Windows was unable to run a specific command within the namespace content, to load additional extensions and component data into Icinga for Windows.';
                'EventId'   = 1103;
            };
            1400 = @{
                'EntryType' = 'Error';
                'Message'   = 'Icinga for Windows background daemon not found';
                'Details'   = 'Icinga for Windows could not find the Function or Cmdlet for the specified background daemon. The daemon was not loaded.';
                'EventId'   = 1400;
            };
            1401 = @{
                'EntryType' = 'Error';
                'Message'   = 'Icinga for Windows thread pool not found';
                'Details'   = 'Icinga for Windows was unable to find a specified thread pool with [Get-IcingaThreadPool] for a background daemon. To keep the daemon running, it defaulted to a basic pool but this issue should be addressed. The name of the inquired pool is:';
                'EventId'   = 1401;
            };
            1450 = @{
                'EntryType' = 'Error';
                'Message'   = 'Icinga for Windows service check daemon invalid index';
                'Details'   = 'Icinga for Windows is unable to process the provided time index for a background service check task, as a given index is not numeric';
                'EventId'   = 1450;
            };
            1451 = @{
                'EntryType' = 'Error';
                'Message'   = 'Icinga for Windows service check daemon exception on plugin execution';
                'Details'   = 'Icinga for Windows failed to execute a plugin within the background service check daemon with an exception';
                'EventId'   = 1451;
            };
            1452 = @{
                'EntryType' = 'Error';
                'Message'   = 'Icinga for Windows service check daemon failed with exception';
                'Details'   = 'Icinga for Windows failed to properly execute a task within the background service check daemon with a given exception';
                'EventId'   = 1452;
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
            1502 = @{
                'EntryType' = 'Error';
                'Message'   = 'Unable to create PowerShell RunSpace in JEA context';
                'Details'   = 'A PowerShell RunSpace for background threads could not be created, as the required Icinga for Windows session configuration file could not be found. Use "Install-IcingaJEAProfile" to resolve this problem.';
                'EventId'   = 1502;
            };
            1503 = @{
                'EntryType' = 'Error';
                'Message'   = 'Unable to start Icinga for Windows service';
                'Details'   = 'Unable to start Icinga for Windows service, as the JEA session created by the service is still active. Run "Restart-IcingaWindowsService" to restart the Icinga for Windows service, while running in JEA context to prevent this issue.';
                'EventId'   = 1503;
            };
            1504 = @{
                'EntryType' = 'Error';
                'Message'   = 'Icinga for Windows JEA context vanished';
                'Details'   = 'The Icinga for Windows JEA session is no longer available. It might have either crashed or get terminated by user actions, like restarting the WinRM service.';
                'EventId'   = 1504;
            };
            1505 = @{
                'EntryType' = 'Warning';
                'Message'   = 'Icinga for Windows JEA context not available';
                'Details'   = 'The Icinga for Windows JEA session is no longer available and is attempted to be restarted on the system. This could have either happenend due to a crash or a user action, like restarting the WinRM service.';
                'EventId'   = 1505;
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
            1600 = @{
                'EntryType' = 'Error';
                'Message'   = 'Exception on function calls in JEA context';
                'Details'   = 'An exception occurred while executing Icinga for Windows code inside a JEA context.';
                'EventId'   = 1600;
            };
        }
    };
}

Export-ModuleMember -Variable @( 'IcingaEventLogEnums' );
