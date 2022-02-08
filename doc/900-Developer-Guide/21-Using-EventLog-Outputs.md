# Developer Guide: Using EventLog Outputs

Windows provides an easy way for managing log content by simply writing it into the EventLog. For this developers can create an own application space to better filter events for the user and to provide context.

The Icinga PowerShell Framework is fully supporting this by providing Cmdlets to write events into the EventLog with proper severities, ids and messages. For troubleshooting it is also supported to dump object informations.

## General Usage Of EventLog Writer

There are two Cmdlets available dealing with the writing into the EventLog. One is for debugging purpose only and the other one is for handling real events.

To simply write debugging information into the EventLog you can use `Write-IcingaDebugMessage` which is fully explained below. There is no special configuration required for this Cmdlet.

The more important Cmdlet is `Write-IcingaEventMessage` which provides some guidelines developers will have to follow which explained below.

### Providing EventLog Content

Unlike other logging mechanisms, the EventLog writer was designed to achieve multiple goals at once:

* Quick and easy to use in projects
* Flexible extendable for custom modules
* Providing documentation for occurring events including the ability to export markdown files

To make use of all these topics, EventLog entries have to be configured for each module within an own function. These functions will have to return a `hashtable` that provides an unique name as `namespace`, followed by event id `hashtables` containing the `EntryType`, a `Message`, additional `Details` and the `EventId`. Please note that `all` of these values are mandatory!

An EventLog hashtable should then look like this:

```powershell
[hashtable]$EventLogEntries = @{
    'MyCustomNamespace' = @{
        2000 = @{
            'EntryType' = 'Error';
            'Message'   = 'Failed to start REST-Api daemon, as no valid provided SSL and Icinga 2 Agent certificate was found';
            'Details'   = 'While starting the Icinga for Windows REST-Api daemon, no valid certificate was found for usage. You can either share a valid certificate by defining the full path with `-CertFile` to a .crt, .cert or .pfx file, by using `-CertThumbprint` to lookup a certificate inside the Microsoft cert store and by default the Icinga 2 Agent certificates. Please note that only Icinga 2 Agent version 2.8.0 or later are supported';
            'EventId'   = 2000;
        };
    };
}
```

In this case `MyCustomNamespace` is the namespace we later refer to. This will prevent modules and possible identical event ids to get into each others way. Within our `MyCustomNamespace` we will then add another `hashtable` which uses an `EventId` as key, followed by another hashtable containing the actual content of the event.

#### EntryType

The `EntryType` will provide the severity which is being written into the EventLog. The following entries are supported:

* Information
* SuccessAudit
* Warning
* Error
* FailureAudit

#### Message

The `Message` should be a short summary of the event for a first impression. Please keep this one as short as possible as the markdown renderer which is explained further below might change in the future to display events even more structured.

#### Details

The details section should provide a more detailed explanation on what went wrong and how the user could resolve this issue or where to look for additional help. This entry is added to the EventLog in addition but separated with newlines from the message itself.

#### EventId

The id the message is being added into the EventLog. This will allow the user to easier filter for certain events and check if a specific event or even an error occurred. For developers the Id range should be between `3000` and `9000`.

### Registering EventLog Content

To register your own EventLog content you will have to add a function following a naming scheme as `namespace` which must always be callable once the module is loaded: `Register-IcingaEventLogMessages{x}`

Replace the `{x}` with a unique name that matches your module name for example, ensuring that this name is **not** taken by another module. Once the Icinga PowerShell Framework is initialised, it will lookup all functions within this namespace and execute them to fetch the EventLog data provided as hashtable. An example for our `MyCustomNamespace` which would be added to our custom module could look like this:

```powershell
function Register-IcingaEventLogMessagesMyCustomNamespace()
{
    return @{
        'MyCustomNamespace' = @{
            2000 = @{
                'EntryType' = 'Error';
                'Message'   = 'Failed to start REST-Api daemon, as no valid provided SSL and Icinga 2 Agent certificate was found';
                'Details'   = 'While starting the Icinga for Windows REST-Api daemon, no valid certificate was found for usage. You can either share a valid certificate by defining the full path with `-CertFile` to a .crt, .cert or .pfx file, by using `-CertThumbprint` to lookup a certificate inside the Microsoft cert store and by default the Icinga 2 Agent certificates. Please note that only Icinga 2 Agent version 2.8.0 or later are supported';
                'EventId'   = 2000;
            };
            2100 = @{
                'EntryType' = 'Warning';
                'Message'   = 'Failed to add namespace configuration for executed commands, as previous commands are reporting identical namespace identifiers';
                'Details'   = 'This warning occurs while the REST-Api is trying to auto-load different resources automatically to provide for example inventory information or any other auto-loaded configurations. Please review your installed modules, check the detailed description which modules and Cmdlets caused this conflict and either resolve it or get in contact with the corresponding developers.';
                'EventId'   = 2100;
            };
        }
    };
}
```

### Using EventLog Writer

Now as our EventLog configuration is complete, we can start using it. For this we will use the Cmdlet `Write-IcingaEventMessage` and provide our `Namespace` for referencing the correct EventLog content as well as the `EventId` for fetching and writing the `EntryType`, `Message` and `Details` as configured into the EventLog.

Following our above example, the call will look like this:

```powershell
Write-IcingaEventMessage -EventId 2000 -Namespace 'MyCustomNamespace';
```

To improve troubleshooting and to provide additional details, we can also add objects into the call with the `-Objects` argument. This argument is an `array` and can hold multiple values:

```powershell
Write-IcingaEventMessage -EventId 2000 -Namespace 'MyCustomNamespace' -Objects 'This is a text dump', 20, (Get-Random);
```

### Using EventLog Debugging

Debugging by using the EventLog is simpler, as it will not require unique ids or any sort of configuration. To write debug message into the EventLog you can use `Write-IcingaDebugMessage`. Instead of providing a `Namespace` or an `EventId`, you can simply add a `Message` including `Objects`. All events are written into the EventLog with id `1000` and severity `information`.

```powershell
Write-IcingaDebugMessage -Message 'This is a debug message being printed into the EventLog' -Objects 'Additional content as text', (Get-Random));
```

**Note:** Debug messages will only be printed if the `debug mode` of the Icinga PowerShell Framework is enabled. To enable the debug mode, you can use `Enable-IcingaFrameworkDebugMode` and to disable it `Disable-IcingaFrameworkDebugMode`. To check if the mode is enabled or disabled you can use `Get-IcingaFrameworkDebugMode`.

### Exporting EventLog Content As Markdown

A huge benefit of the implementation we choose is the possibility to export the EventLog configuration as markdown, making it easier for providing them on GitHub for example. For this we can use the Cmdlet `Publish-IcingaEventLogDocumentation` and provide the namespace for the EventLog to export and a destination file.

```powershell
Publish-IcingaEventLogDocumentation -Namespace 'Framework' -OutFile 'C:\users\public\EventLog-doc.md':
```

An example on how the exported result looks like can be found on the [Framework EventLog Documentation](../100-General/20-Eventlog.md).
