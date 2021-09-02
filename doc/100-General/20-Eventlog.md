# Icinga for Windows Eventlog Documentation

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

## Event Id 1550

| Category | Short Message | Detailed Message |
| --- | --- | --- |
| Error | Unsupported web authentication used | A web client tried to authenticate with an unsupported authorization method. |

## Event Id 1551

| Category | Short Message | Detailed Message |
| --- | --- | --- |
| Warning | Invalid authentication credentials provided | A web request for a client was rejected because of invalid formated base64 encoded credentials. |

## Event Id 1552

| Category | Short Message | Detailed Message |
| --- | --- | --- |
| Error | Failed to parse use credentials from base64 encoding | Provided user credentials encoded as base64 could not be converted to domain, user and password objects. |

## Event Id 1560

| Category | Short Message | Detailed Message |
| --- | --- | --- |
| Error | Failed to test user login as no Principal Context could be established | A web client trying to authenticate failed as no Principal Context for the provided domain could be established. |

## Event Id 1561

| Category | Short Message | Detailed Message |
| --- | --- | --- |
| Error | Failed to authenticate user with given credentials | A web client trying to authenticate failed as the provided user credentials could not be verified. |
