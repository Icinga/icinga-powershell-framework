# Framework EventLog Documentation

Below you will find a list of EventId's which are exported by this module. The short and detailed message are both written directly into the EventLog. This documentation shall simply provide a summary of available EventId's

## Event Id 1000

| Category | Short Message | Detailed Message |
| --- | --- | --- |
| Information | Generic debug message issued by the Framework or its components | The Framework or is components can issue generic debug message in case the debug log is enabled. Please ensure to disable it, if not used. You can do so with the command "Disable-IcingaFrameworkDebugMode" |

## Event Id 1001

| Category | Short Message | Detailed Message |
| --- | --- | --- |
| Warning | Icinga for Windows deprecation warning | Icinga for Windows or one of its components executed a function or method, which is flagged as deprecated. Please modify your code or contact the responsible developer to update the component to no longer user this deprecated function or method. |

## Event Id 1100

| Category | Short Message | Detailed Message |
| --- | --- | --- |
| Error | Corrupt Icinga for Windows configuration | Your Icinga for Windows configuration file was corrupt and could not be read successfully. A new configuration file was created and the old one renamed for review, to keep your settings available. |

## Event Id 1101

| Category | Short Message | Detailed Message |
| --- | --- | --- |
| Warning | Unable to update Icinga for Windows file | Icinga for Windows could not update the specified file after several attempts, because another process is locking it. Modifications made on the file have not been persisted. |

## Event Id 1102

| Category | Short Message | Detailed Message |
| --- | --- | --- |
| Warning | Unable to read Icinga for Windows content file | Icinga for Windows could not read the specified file after several attempts, because another process is locking the file. Icinga for Windows terminated itself to prevent damage to this file. |

## Event Id 1103

| Category | Short Message | Detailed Message |
| --- | --- | --- |
| Error | Failed to load Icinga for Windows namespace content | Icinga for Windows was unable to run a specific command within the namespace content, to load additional extensions and component data into Icinga for Windows. |

## Event Id 1400

| Category | Short Message | Detailed Message |
| --- | --- | --- |
| Error | Icinga for Windows background daemon not found | Icinga for Windows could not find the Function or Cmdlet for the specified background daemon. The daemon was not loaded. |

## Event Id 1500

| Category | Short Message | Detailed Message |
| --- | --- | --- |
| Error | Failed to securely establish a communication between this server and the client | A client connection could not be established to this server. This issue is mostly caused by using Self-Signed/Icinga 2 Agent certificates for the server and the client not trusting the certificate. To resolve this issue, either use trusted certificates signed by your trusted CA or setup the client to accept untrusted certificates |

## Event Id 1501

| Category | Short Message | Detailed Message |
| --- | --- | --- |
| Error | Client connection was interrupted because of invalid SSL stream | A client connection was terminated by the Framework because no secure SSL handshake could be established. This issue in general is followed by EventId 1500. |

## Event Id 1502

| Category | Short Message | Detailed Message |
| --- | --- | --- |
| Error | Unable to create PowerShell RunSpace in JEA context | A PowerShell RunSpace for background threads could not be created, as the required Icinga for Windows session configuration file could not be found. Use "Install-IcingaJEAProfile" to resolve this problem. |

## Event Id 1503

| Category | Short Message | Detailed Message |
| --- | --- | --- |
| Error | Unable to start Icinga for Windows service | Unable to start Icinga for Windows service, as the JEA session created by the service is still active. Run "Restart-IcingaWindowsService" to restart the Icinga for Windows service, while running in JEA context to prevent this issue. |

## Event Id 1504

| Category | Short Message | Detailed Message |
| --- | --- | --- |
| Error | Icinga for Windows JEA context vanished | The Icinga for Windows JEA session is no longer available. It might have either crashed or get terminated by user actions, like restarting the WinRM service. |

## Event Id 1505

| Category | Short Message | Detailed Message |
| --- | --- | --- |
| Warning | Icinga for Windows JEA context not available | The Icinga for Windows JEA session is no longer available and is attempted to be restarted on the system. This could have either happened due to a crash or a user action, like restarting the WinRM service. |

## Event Id 1550

| Category | Short Message | Detailed Message |
| --- | --- | --- |
| Error | Unsupported web authentication used | A web client tried to authenticate with an unsupported authorization method. |

## Event Id 1551

| Category | Short Message | Detailed Message |
| --- | --- | --- |
| Warning | Invalid authentication credentials provided | A web request for a client was rejected because of invalid formatted base64 encoded credentials. |

## Event Id 1552

| Category | Short Message | Detailed Message |
| --- | --- | --- |
| Error | Failed to parse use credentials from base64 encoding | Provided user credentials encoded as base64 could not be converted to domain, user and password objects. |

## Event Id 1553

| Category | Short Message | Detailed Message |
| --- | --- | --- |
| Error | Failed to query Icinga check over internal REST-Api check handler | A service check could not be executed by using the internal REST-Api check handler. The check either ran into a timeout or could not be processed. Maybe the check was not registered to be allowed for being executed. Further details can be found below. |

## Event Id 1560

| Category | Short Message | Detailed Message |
| --- | --- | --- |
| Error | Failed to test user login as no Principal Context could be established | A web client trying to authenticate failed as no Principal Context for the provided domain could be established. |

## Event Id 1561

| Category | Short Message | Detailed Message |
| --- | --- | --- |
| Error | Failed to authenticate user with given credentials | A web client trying to authenticate failed as the provided user credentials could not be verified. |

## Event Id 1600

| Category | Short Message | Detailed Message |
| --- | --- | --- |
| Error | Exception on function calls in JEA context | An exception occurred while executing Icinga for Windows code inside a JEA context. |
