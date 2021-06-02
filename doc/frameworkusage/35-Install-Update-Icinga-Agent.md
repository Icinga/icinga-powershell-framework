# Install/Update Icinga Agent

Managing the Icinga Agent is one of the main goals for Icinga for Windows. This also includes installing and updating the Icinga Agent itself.

**Note:** Before using any of the commands below you will have to initialize the Icinga PowerShell Framework inside a new PowerShell instance with `Use-Icinga`. Starting with version `1.2.0` of the Framework you can also simply type `icinga` into the command line.

## Installing the Icinga Agent

The Icinga PowerShell Framework ships with a simple Cmdlet to install/update the Icinga Agent, called `Install-IcingaAgent`. It includes a bunch of arguments for managing sources, install location, versions and handling of updates.

### Install Latest Icinga Agent

To simply install the latest version of the Icinga Agent, you can run the following command:

```powershell
Install-IcingaAgent -Version 'release'
```

This will lookup the default installation source `https://packages.icinga.com/windows/`, fetch the latest version, download and install it.

### Install Specific Icinga Agent version

To install a specific version of the Icinga Agent, you can set the version argument to the intended version:

```powershell
Install-IcingaAgent -Version '2.11.6'
```

This will download Icinga Agent `2.11.6` from `https://packages.icinga.com/windows/` and install it

### Update Icinga Agent

Similar to the above examples, you can also update or downgrade the Icinga Agent with this command. All argument handling as before applies. However, to tell the command to perform an upgrade or downgrade, you will have to set the argument `-AllowUpdates` in addition (which also applies to downgrades):

```powershell
Install-IcingaAgent -Version 'release' -AllowUpdates 1
```

## Customizing the Installer

Of course, you can also modify the `Install-IcingaAgent` command with different arguments besides `-Version` and `-AllowUpdates`. This is the list of supported arguments:

| Argument      | Type   | Default                              | Description |
| ---           | ---    | ---                                  | ---         |
| AllowUpdates | bool   | 0                                    | Tells the command to either upgrade or downgrade the Icinga Agent version if the target version is not matching the current one. Has either to be `0` (not allowing up-/downgrades) or `1` (allow up/downgrades) |
| InstallDir   | string |`C:\Program Files\ICINGA2`            | Allows to override the default installation location `C:\Program Files\ICINGA2` with a custom location |
| Source       | string | https://packages.icinga.com/windows/ | The location to lookup for Icinga Agent `.msi` installers. This can either be a web, local or network share. If you define a custom web share, please ensure that the directory containing the `.msi` packages is granted to list it's file content |
| Version      | string |                                      | Specify the version you want to install for the Icinga Agent. You can use `latest` to fetch the latest version available on the specified location, `snapshot` to fetch a snapshot version and a specific version like `2.11.6` |

For example we can distribute Icinga Agents over a local network share for better update management.

```powershell
Install-IcingaAgent -Version 'release' -AllowUpdates 1 -Source '\\example.com\icinga\icingaagent\'
```
