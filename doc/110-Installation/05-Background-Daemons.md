# Background Daemons - Installation

Icinga for Windows supports to run tasks within a background daemon, allowing to collect metrics over time, providing a REST-Api and other functionality.

## Requirements

In order to work with background daemons, you will require to have the Icinga for Windows PowerShell service installed. You can do this during the initial run within the IMC, by installing the `service` component inside the IMC or by running the following command:

```powershell
Install-IcingaComponent -Name service;
```

**Note:** To install the service you require to add a [Icinga for Windows repository](20-Install-Components.md) to your environment.

## Managing Background Daemons

You can register, unregister and show background daemons including the configuration. Some background daemons might ship with independent configurations and possibilities, please have a look on the corresponding documentation.

### Register Background Daemons

In order to register a background daemon, you can run the command

```powershell
Register-IcingaBackgroundDaemon;
```

| Argument  | Type       | Description |
| ---       | ---        | ---         |
| Command   | String     | The name of the command being registered as background daemon. The command has to be defined of type background daemon. You cannot register any other command |
| Arguments | Hashtable  | In case background daemons allow the configuration and definition of arguments, you can set them as hashtable with this argument |

Icinga for Windows ships with an internal daemon to collect metrics over time. The daemon function is `Start-IcingaServiceCheckDaemon`:

```powershell
Register-IcingaBackgroundDaemon `
    -Command 'Start-IcingaServiceCheckDaemon';
```

In case the daemon is using arguments, you can provide the key/value pair for the argument as a hashtable. In case the argument is of type `Switch`, simply set the value to `$True` to add the argument.

```powershell
Register-IcingaBackgroundDaemon `
    -Command 'Start-MyCustomDaemon' `
    -Arguments @{
        '-MySwitchParameter'  = $True;
        '-MyIntegerParameter' = 42;
        '-MyStringParameter'  = 'Example';
    };
```

### Unregister Background Daemons

Once a daemon is registered, you can also unregister them from Icinga for Windows.

```powershell
Unregister-IcingaBackgroundDaemon 'Start-IcingaServiceCheckDaemon';
```

### Show Background Daemons

To print a list of configured background daemons, you can run

```powershell
Show-IcingaRegisteredBackgroundDaemons;
```

```powershell
List of configured background daemons on this system.

Start-IcingaServiceCheckDaemon
-----------
No arguments defined
```

## Restart PowerShell Service

In order to apply any changes on background daemons, you will always to restart the Icinga for Windows PowerShell service. You can do so with the following command:

```powershell
Restart-IcingaForWindows;
```
