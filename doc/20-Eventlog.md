# Framework Eventlog Documentation

Below you will find a list of EventId's which are exported by this module. The short and detailed message are both written directly into the eventlog. This documentation shall simply provide a summary of available EventId's

## Event Id 1000

| Category | Short Message | Detailed Message |
| --- | --- | --- |
| Information | Generic debug message issued by the Framework or its components | The Framework or is components can issue generic debug message in case the debug log is enabled. Please ensure to disable it, if not used. You can do so with the command "Disable-IcingaFrameworkDebugMode" |

## Event Id 1500

| Category | Short Message | Detailed Message |
| --- | --- | --- |
| Error | Failed to securely establish a communiation between this server and the client | A client connection could not be established to this server. This issue is mostly caused by using Self-Signed/Icinga 2 Agent certificates for the server and the client not trusting the certificate. To resolve this issue, either use trusted certificates signed by your trusted CA or setup the client to accept untrusted certificates |

## Event Id 1501

| Category | Short Message | Detailed Message |
| --- | --- | --- |
| Error | Client connection was interrupted because of invalid SSL stream | A client connection was terminated by the Framework because no secure SSL handshake could be established. This issue in general is followed by EventId 1500. |
